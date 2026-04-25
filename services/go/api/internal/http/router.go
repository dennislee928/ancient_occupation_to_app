package http

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	nethttp "net/http"
	"strings"
	"time"

	"ancient_occupation_to_app/services/go/api/internal/auth"
	"ancient_occupation_to_app/services/go/api/internal/config"
	"ancient_occupation_to_app/services/go/api/internal/dto"
	"ancient_occupation_to_app/services/go/api/internal/features/devices"
	"ancient_occupation_to_app/services/go/api/internal/features/nomenclator"
	"ancient_occupation_to_app/services/go/api/internal/features/profiles"
	"ancient_occupation_to_app/services/go/api/internal/vto"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/jackc/pgx/v5/pgxpool"
)

type App struct {
	config          config.Config
	pool            *pgxpool.Pool
	startedAt       time.Time
	profilesRepo    profiles.Repository
	devicesRepo     devices.Repository
	nomenclatorRepo nomenclator.Repository
}

func NewRouter(cfg config.Config, pool *pgxpool.Pool) nethttp.Handler {
	app := App{
		config:          cfg,
		pool:            pool,
		startedAt:       time.Now().UTC(),
		profilesRepo:    profiles.NewRepository(pool),
		devicesRepo:     devices.NewRepository(pool),
		nomenclatorRepo: nomenclator.NewRepository(pool),
	}

	r := chi.NewRouter()
	r.Use(middleware.RequestID)
	r.Use(middleware.RealIP)
	r.Use(middleware.Recoverer)
	r.Use(middleware.Timeout(15 * time.Second))

	r.Get("/healthz", app.healthz)
	r.Get("/readyz", app.readyz)

	r.Route("/v1", func(r chi.Router) {
		r.Use(app.requireAuth)

		r.Get("/me", app.getMe)
		r.Patch("/me", app.patchMe)
		r.Post("/devices/register", app.registerDevice)

		r.Route("/nomenclator", func(r chi.Router) {
			r.Get("/people", app.listPeopleCards)
			r.Post("/people", app.createPersonCard)
			r.Post("/sessions", app.createSession)
			r.Get("/sessions/{sessionID}", app.getSession)
			r.Post("/sessions/{sessionID}/prompts", app.createPrompt)
		})
	})

	return r
}

func (app App) healthz(w nethttp.ResponseWriter, _ *nethttp.Request) {
	writeJSON(w, nethttp.StatusOK, map[string]any{
		"service":     "go-api",
		"status":      "ok",
		"environment": app.config.AppEnv,
		"uptime_sec":  int(time.Since(app.startedAt).Seconds()),
	})
}

func (app App) readyz(w nethttp.ResponseWriter, r *nethttp.Request) {
	if app.pool == nil {
		writeError(w, nethttp.StatusServiceUnavailable, "SUPABASE_DATABASE_URL is not configured")
		return
	}

	ctx, cancel := context.WithTimeout(r.Context(), 2*time.Second)
	defer cancel()

	if err := app.pool.Ping(ctx); err != nil {
		writeError(w, nethttp.StatusServiceUnavailable, err.Error())
		return
	}

	writeJSON(w, nethttp.StatusOK, map[string]any{
		"service": "go-api",
		"status":  "ready",
	})
}

func (app App) requireAuth(next nethttp.Handler) nethttp.Handler {
	return nethttp.HandlerFunc(func(w nethttp.ResponseWriter, r *nethttp.Request) {
		debugUserID := strings.TrimSpace(r.Header.Get("X-Debug-User-ID"))
		if debugUserID != "" && app.config.AppEnv != "production" {
			next.ServeHTTP(w, r.WithContext(auth.WithUser(r.Context(), auth.User{ID: debugUserID})))
			return
		}

		authorization := strings.TrimSpace(r.Header.Get("Authorization"))
		if authorization == "" {
			writeError(w, nethttp.StatusUnauthorized, "missing authorization header")
			return
		}

		token, ok := strings.CutPrefix(authorization, "Bearer ")
		if !ok || strings.TrimSpace(token) == "" {
			writeError(w, nethttp.StatusUnauthorized, "authorization header must be a bearer token")
			return
		}

		if app.config.SupabaseJWTSecret == "" {
			writeError(w, nethttp.StatusUnauthorized, "SUPABASE_JWT_SECRET is not configured; use X-Debug-User-ID in development")
			return
		}

		user, err := auth.VerifyHS256Token(strings.TrimSpace(token), app.config.SupabaseJWTSecret)
		if err != nil {
			writeError(w, nethttp.StatusUnauthorized, err.Error())
			return
		}

		next.ServeHTTP(w, r.WithContext(auth.WithUser(r.Context(), user)))
	})
}

func (app App) getMe(w nethttp.ResponseWriter, r *nethttp.Request) {
	user, ok := auth.UserFromContext(r.Context())
	if !ok {
		writeError(w, nethttp.StatusUnauthorized, "missing authenticated user")
		return
	}

	profile, err := app.profilesRepo.GetOrCreateByUserID(r.Context(), user.ID)
	if err != nil {
		writeRepositoryError(w, err)
		return
	}

	writeJSON(w, nethttp.StatusOK, map[string]any{"profile": mapProfile(profile)})
}

func (app App) patchMe(w nethttp.ResponseWriter, r *nethttp.Request) {
	user, ok := auth.UserFromContext(r.Context())
	if !ok {
		writeError(w, nethttp.StatusUnauthorized, "missing authenticated user")
		return
	}

	var input dto.UpdateProfileRequest
	if err := decodeJSON(r, &input); err != nil {
		writeError(w, nethttp.StatusBadRequest, err.Error())
		return
	}

	profile, err := app.profilesRepo.UpdateByUserID(r.Context(), user.ID, input)
	if err != nil {
		writeRepositoryError(w, err)
		return
	}

	writeJSON(w, nethttp.StatusOK, map[string]any{"profile": mapProfile(profile)})
}

func (app App) registerDevice(w nethttp.ResponseWriter, r *nethttp.Request) {
	user, ok := auth.UserFromContext(r.Context())
	if !ok {
		writeError(w, nethttp.StatusUnauthorized, "missing authenticated user")
		return
	}

	var input dto.RegisterDeviceRequest
	if err := decodeJSON(r, &input); err != nil {
		writeError(w, nethttp.StatusBadRequest, err.Error())
		return
	}

	registration, err := app.devicesRepo.Register(r.Context(), user.ID, input)
	if err != nil {
		writeRepositoryError(w, err)
		return
	}

	writeJSON(w, nethttp.StatusOK, map[string]any{"device": mapDeviceRegistration(registration)})
}

func (app App) listPeopleCards(w nethttp.ResponseWriter, r *nethttp.Request) {
	user, ok := auth.UserFromContext(r.Context())
	if !ok {
		writeError(w, nethttp.StatusUnauthorized, "missing authenticated user")
		return
	}

	cards, err := app.nomenclatorRepo.ListPeople(r.Context(), user.ID)
	if err != nil {
		writeRepositoryError(w, err)
		return
	}

	response := make([]vto.PersonCard, 0, len(cards))
	for _, card := range cards {
		response = append(response, mapPersonCard(card))
	}

	writeJSON(w, nethttp.StatusOK, map[string]any{"people": response})
}

func (app App) createPersonCard(w nethttp.ResponseWriter, r *nethttp.Request) {
	user, ok := auth.UserFromContext(r.Context())
	if !ok {
		writeError(w, nethttp.StatusUnauthorized, "missing authenticated user")
		return
	}

	var input dto.CreatePersonCardRequest
	if err := decodeJSON(r, &input); err != nil {
		writeError(w, nethttp.StatusBadRequest, err.Error())
		return
	}

	card, err := app.nomenclatorRepo.CreatePersonCard(r.Context(), user.ID, input)
	if err != nil {
		writeRepositoryError(w, err)
		return
	}

	writeJSON(w, nethttp.StatusCreated, map[string]any{"person": mapPersonCard(card)})
}

func (app App) createSession(w nethttp.ResponseWriter, r *nethttp.Request) {
	user, ok := auth.UserFromContext(r.Context())
	if !ok {
		writeError(w, nethttp.StatusUnauthorized, "missing authenticated user")
		return
	}

	var input dto.CreateEncounterSessionRequest
	if err := decodeJSON(r, &input); err != nil {
		writeError(w, nethttp.StatusBadRequest, err.Error())
		return
	}

	session, err := app.nomenclatorRepo.CreateSession(r.Context(), user.ID, input)
	if err != nil {
		writeRepositoryError(w, err)
		return
	}

	writeJSON(w, nethttp.StatusCreated, map[string]any{"session": mapEncounterSession(session, nil)})
}

func (app App) getSession(w nethttp.ResponseWriter, r *nethttp.Request) {
	user, ok := auth.UserFromContext(r.Context())
	if !ok {
		writeError(w, nethttp.StatusUnauthorized, "missing authenticated user")
		return
	}

	details, err := app.nomenclatorRepo.GetSessionDetails(r.Context(), user.ID, chi.URLParam(r, "sessionID"))
	if err != nil {
		writeRepositoryError(w, err)
		return
	}

	writeJSON(w, nethttp.StatusOK, map[string]any{"session": mapEncounterSession(details.Session, details.Prompts)})
}

func (app App) createPrompt(w nethttp.ResponseWriter, r *nethttp.Request) {
	user, ok := auth.UserFromContext(r.Context())
	if !ok {
		writeError(w, nethttp.StatusUnauthorized, "missing authenticated user")
		return
	}

	var input dto.CreatePromptMessageRequest
	if err := decodeJSON(r, &input); err != nil {
		writeError(w, nethttp.StatusBadRequest, err.Error())
		return
	}

	prompt, err := app.nomenclatorRepo.AddPrompt(r.Context(), user.ID, chi.URLParam(r, "sessionID"), input)
	if err != nil {
		writeRepositoryError(w, err)
		return
	}

	writeJSON(w, nethttp.StatusCreated, map[string]any{"prompt": mapPrompt(prompt)})
}

func writeRepositoryError(w nethttp.ResponseWriter, err error) {
	status := nethttp.StatusInternalServerError
	if strings.Contains(err.Error(), "not found") {
		status = nethttp.StatusNotFound
	} else if strings.Contains(err.Error(), "required") || strings.Contains(err.Error(), "must be") {
		status = nethttp.StatusBadRequest
	} else if strings.Contains(err.Error(), "not configured") {
		status = nethttp.StatusServiceUnavailable
	}

	writeError(w, status, err.Error())
}

func decodeJSON(r *nethttp.Request, target any) error {
	defer r.Body.Close()

	decoder := json.NewDecoder(r.Body)
	decoder.DisallowUnknownFields()

	if err := decoder.Decode(target); err != nil {
		return fmt.Errorf("decode json body: %w", err)
	}

	if err := decoder.Decode(&struct{}{}); err != nil && !errors.Is(err, io.EOF) {
		return errors.New("json body must contain a single object")
	}

	return nil
}

func writeError(w nethttp.ResponseWriter, status int, message string) {
	writeJSON(w, status, map[string]any{
		"error": map[string]any{
			"message": message,
		},
	})
}

func writeJSON(w nethttp.ResponseWriter, status int, payload map[string]any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(payload)
}
