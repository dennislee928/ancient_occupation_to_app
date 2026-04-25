package http

import (
	"context"
	"encoding/json"
	"net/http"
	"time"

	"ancient_occupation_to_app/services/go/api/internal/config"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/jackc/pgx/v5/pgxpool"
)

type Router struct {
	config    config.Config
	pool      *pgxpool.Pool
	startedAt time.Time
}

func NewRouter(cfg config.Config, pool *pgxpool.Pool) http.Handler {
	app := Router{
		config:    cfg,
		pool:      pool,
		startedAt: time.Now().UTC(),
	}

	r := chi.NewRouter()
	r.Use(middleware.RequestID)
	r.Use(middleware.RealIP)
	r.Use(middleware.Recoverer)

	r.Get("/healthz", app.healthz)
	r.Get("/readyz", app.readyz)

	return r
}

func (app Router) healthz(w http.ResponseWriter, _ *http.Request) {
	writeJSON(w, http.StatusOK, map[string]any{
		"service":     "go-api",
		"status":      "ok",
		"environment": app.config.AppEnv,
		"uptime_sec":  int(time.Since(app.startedAt).Seconds()),
	})
}

func (app Router) readyz(w http.ResponseWriter, r *http.Request) {
	if app.pool == nil {
		writeJSON(w, http.StatusServiceUnavailable, map[string]any{
			"service": "go-api",
			"status":  "not_ready",
			"reason":  "SUPABASE_DATABASE_URL is not configured",
		})
		return
	}

	ctx, cancel := context.WithTimeout(r.Context(), 2*time.Second)
	defer cancel()

	if err := app.pool.Ping(ctx); err != nil {
		writeJSON(w, http.StatusServiceUnavailable, map[string]any{
			"service": "go-api",
			"status":  "not_ready",
			"reason":  err.Error(),
		})
		return
	}

	writeJSON(w, http.StatusOK, map[string]any{
		"service": "go-api",
		"status":  "ready",
	})
}

func writeJSON(w http.ResponseWriter, status int, payload map[string]any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(payload)
}
