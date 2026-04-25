package profiles

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

func (repo Repository) GetOrCreateByUserID(ctx context.Context, userID string) (Profile, error) {
	if repo.pool == nil {
		return Profile{}, errors.New("database is not configured")
	}

	query := `
insert into public.profiles (user_id)
values ($1)
on conflict (user_id) do update
set user_id = excluded.user_id
returning id::text, user_id::text, display_name, avatar_url, created_at, updated_at
`

	var profile Profile
	err := repo.pool.QueryRow(ctx, query, userID).Scan(
		&profile.ID,
		&profile.UserID,
		&profile.DisplayName,
		&profile.AvatarURL,
		&profile.CreatedAt,
		&profile.UpdatedAt,
	)
	if err != nil {
		return Profile{}, fmt.Errorf("load profile: %w", err)
	}

	return profile, nil
}

func (repo Repository) UpdateByUserID(ctx context.Context, userID string, input dto.UpdateProfileRequest) (Profile, error) {
	if repo.pool == nil {
		return Profile{}, errors.New("database is not configured")
	}

	query := `
insert into public.profiles (user_id, display_name, avatar_url)
values ($1, $2, $3)
on conflict (user_id) do update
set
  display_name = coalesce($2, public.profiles.display_name),
  avatar_url = coalesce($3, public.profiles.avatar_url),
  updated_at = now()
returning id::text, user_id::text, display_name, avatar_url, created_at, updated_at
`

	var profile Profile
	err := repo.pool.QueryRow(
		ctx,
		query,
		userID,
		trimNullable(input.DisplayName),
		trimNullable(input.AvatarURL),
	).Scan(
		&profile.ID,
		&profile.UserID,
		&profile.DisplayName,
		&profile.AvatarURL,
		&profile.CreatedAt,
		&profile.UpdatedAt,
	)
	if err != nil {
		return Profile{}, fmt.Errorf("update profile: %w", err)
	}

	return profile, nil
}

func trimNullable(value *string) *string {
	if value == nil {
		return nil
	}

	trimmed := strings.TrimSpace(*value)
	if trimmed == "" {
		return nil
	}

	return &trimmed
}
