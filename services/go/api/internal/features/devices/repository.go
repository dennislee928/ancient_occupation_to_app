package devices

import (
	"context"
	"errors"
	"fmt"
	"strings"

	"ancient_occupation_to_app/services/go/api/internal/dto"

	"github.com/jackc/pgx/v5/pgxpool"
)

type Repository struct {
	pool *pgxpool.Pool
}

func NewRepository(pool *pgxpool.Pool) Repository {
	return Repository{pool: pool}
}

func (repo Repository) Register(ctx context.Context, userID string, input dto.RegisterDeviceRequest) (Registration, error) {
	if repo.pool == nil {
		return Registration{}, errors.New("database is not configured")
	}

	platform := strings.TrimSpace(strings.ToLower(input.Platform))
	pushProvider := strings.TrimSpace(strings.ToLower(input.PushProvider))
	pushToken := strings.TrimSpace(input.PushToken)
	if platform != "ios" && platform != "android" {
		return Registration{}, errors.New("platform must be ios or android")
	}
	if pushProvider != "apns" && pushProvider != "fcm" {
		return Registration{}, errors.New("push_provider must be apns or fcm")
	}
	if pushToken == "" {
		return Registration{}, errors.New("push_token is required")
	}

	query := `
insert into public.user_devices (
  user_id,
  platform,
  push_token,
  push_provider,
  app_version,
  last_seen_at,
  updated_at
) values ($1, $2, $3, $4, $5, now(), now())
on conflict (push_token) do update
set
  user_id = excluded.user_id,
  platform = excluded.platform,
  push_provider = excluded.push_provider,
  app_version = excluded.app_version,
  last_seen_at = now(),
  updated_at = now()
returning id::text, user_id::text, platform, push_token, push_provider, app_version, last_seen_at, created_at, updated_at
`

	var registration Registration
	err := repo.pool.QueryRow(
		ctx,
		query,
		userID,
		platform,
		pushToken,
		pushProvider,
		input.AppVersion,
	).Scan(
		&registration.ID,
		&registration.UserID,
		&registration.Platform,
		&registration.PushToken,
		&registration.PushProvider,
		&registration.AppVersion,
		&registration.LastSeenAt,
		&registration.CreatedAt,
		&registration.UpdatedAt,
	)
	if err != nil {
		return Registration{}, fmt.Errorf("register device: %w", err)
	}

	return registration, nil
}
