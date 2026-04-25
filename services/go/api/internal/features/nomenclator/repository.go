package nomenclator

import (
	"context"
	"errors"
	"fmt"
	"strings"

	"ancient_occupation_to_app/services/go/api/internal/dto"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type Repository struct {
	pool *pgxpool.Pool
}

type SessionDetails struct {
	Session EncounterSession
	Prompts []PromptMessage
}

func NewRepository(pool *pgxpool.Pool) Repository {
	return Repository{pool: pool}
}

func (repo Repository) ListPeople(ctx context.Context, ownerUserID string) ([]PersonCard, error) {
	if repo.pool == nil {
		return nil, errors.New("database is not configured")
	}

	rows, err := repo.pool.Query(ctx, `
select id::text, owner_user_id::text, name, affiliation, notes, created_at, updated_at
from public.people_cards
where owner_user_id = $1
order by updated_at desc, created_at desc
`, ownerUserID)
	if err != nil {
		return nil, fmt.Errorf("list people cards: %w", err)
	}
	defer rows.Close()

	var cards []PersonCard
	for rows.Next() {
		var card PersonCard
		if err := rows.Scan(
			&card.ID,
			&card.OwnerUserID,
			&card.Name,
			&card.Affiliation,
			&card.Notes,
			&card.CreatedAt,
			&card.UpdatedAt,
		); err != nil {
			return nil, fmt.Errorf("scan person card: %w", err)
		}
		cards = append(cards, card)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate people cards: %w", err)
	}

	return cards, nil
}

func (repo Repository) CreatePersonCard(ctx context.Context, ownerUserID string, input dto.CreatePersonCardRequest) (PersonCard, error) {
	if repo.pool == nil {
		return PersonCard{}, errors.New("database is not configured")
	}

	name := strings.TrimSpace(input.Name)
	if name == "" {
		return PersonCard{}, errors.New("name is required")
	}

	query := `
insert into public.people_cards (owner_user_id, name, affiliation, notes)
values ($1, $2, $3, $4)
returning id::text, owner_user_id::text, name, affiliation, notes, created_at, updated_at
`

	var card PersonCard
	err := repo.pool.QueryRow(ctx, query, ownerUserID, name, trimNullable(input.Affiliation), trimNullable(input.Notes)).Scan(
		&card.ID,
		&card.OwnerUserID,
		&card.Name,
		&card.Affiliation,
		&card.Notes,
		&card.CreatedAt,
		&card.UpdatedAt,
	)
	if err != nil {
		return PersonCard{}, fmt.Errorf("create person card: %w", err)
	}

	return card, nil
}

func (repo Repository) CreateSession(ctx context.Context, ownerUserID string, input dto.CreateEncounterSessionRequest) (EncounterSession, error) {
	if repo.pool == nil {
		return EncounterSession{}, errors.New("database is not configured")
	}

	personCardID := strings.TrimSpace(input.PersonCardID)
	if personCardID == "" {
		return EncounterSession{}, errors.New("person_card_id is required")
	}

	tx, err := repo.pool.BeginTx(ctx, pgx.TxOptions{})
	if err != nil {
		return EncounterSession{}, fmt.Errorf("begin session transaction: %w", err)
	}
	defer tx.Rollback(ctx)

	var ownedCardID string
	err = tx.QueryRow(
		ctx,
		`select id::text from public.people_cards where id = $1 and owner_user_id = $2`,
		personCardID,
		ownerUserID,
	).Scan(&ownedCardID)
	if errors.Is(err, pgx.ErrNoRows) {
		return EncounterSession{}, errors.New("person card not found")
	}
	if err != nil {
		return EncounterSession{}, fmt.Errorf("load person card: %w", err)
	}

	query := `
insert into public.encounter_sessions (
  owner_user_id,
  companion_user_id,
  person_card_id,
  context_label,
  status
)
values ($1, $2, $3, $4, 'active')
returning id::text, owner_user_id::text, companion_user_id::text, person_card_id::text, context_label, status, created_at
`

	var session EncounterSession
	err = tx.QueryRow(
		ctx,
		query,
		ownerUserID,
		trimNullable(input.CompanionUser),
		personCardID,
		trimNullable(input.ContextLabel),
	).Scan(
		&session.ID,
		&session.OwnerUserID,
		&session.CompanionUserID,
		&session.PersonCardID,
		&session.ContextLabel,
		&session.Status,
		&session.CreatedAt,
	)
	if err != nil {
		return EncounterSession{}, fmt.Errorf("create encounter session: %w", err)
	}

	if err := tx.Commit(ctx); err != nil {
		return EncounterSession{}, fmt.Errorf("commit encounter session: %w", err)
	}

	return session, nil
}

func (repo Repository) AddPrompt(ctx context.Context, actorUserID, sessionID string, input dto.CreatePromptMessageRequest) (PromptMessage, error) {
	if repo.pool == nil {
		return PromptMessage{}, errors.New("database is not configured")
	}

	body := strings.TrimSpace(input.Body)
	deliveryMode := strings.TrimSpace(strings.ToLower(input.DeliveryMode))
	if body == "" {
		return PromptMessage{}, errors.New("body is required")
	}
	if deliveryMode == "" {
		deliveryMode = "manual"
	}
	if deliveryMode != "manual" && deliveryMode != "quiet" && deliveryMode != "urgent" {
		return PromptMessage{}, errors.New("delivery_mode must be manual, quiet, or urgent")
	}

	tx, err := repo.pool.BeginTx(ctx, pgx.TxOptions{})
	if err != nil {
		return PromptMessage{}, fmt.Errorf("begin prompt transaction: %w", err)
	}
	defer tx.Rollback(ctx)

	var allowed bool
	err = tx.QueryRow(
		ctx,
		`select exists(
      select 1
      from public.encounter_sessions
      where id = $1
        and status = 'active'
        and (owner_user_id = $2 or companion_user_id = $2)
    )`,
		sessionID,
		actorUserID,
	).Scan(&allowed)
	if err != nil {
		return PromptMessage{}, fmt.Errorf("authorize session prompt: %w", err)
	}
	if !allowed {
		return PromptMessage{}, errors.New("encounter session not found")
	}

	var prompt PromptMessage
	err = tx.QueryRow(
		ctx,
		`
insert into public.prompt_messages (session_id, sender_user_id, body, delivery_mode)
values ($1, $2, $3, $4)
returning id::text, session_id::text, sender_user_id::text, body, delivery_mode, created_at
`,
		sessionID,
		actorUserID,
		body,
		deliveryMode,
	).Scan(
		&prompt.ID,
		&prompt.SessionID,
		&prompt.SenderUserID,
		&prompt.Body,
		&prompt.DeliveryMode,
		&prompt.CreatedAt,
	)
	if err != nil {
		return PromptMessage{}, fmt.Errorf("insert prompt message: %w", err)
	}

	if err := tx.Commit(ctx); err != nil {
		return PromptMessage{}, fmt.Errorf("commit prompt transaction: %w", err)
	}

	return prompt, nil
}

func (repo Repository) GetSessionDetails(ctx context.Context, actorUserID, sessionID string) (SessionDetails, error) {
	if repo.pool == nil {
		return SessionDetails{}, errors.New("database is not configured")
	}

	var details SessionDetails
	err := repo.pool.QueryRow(
		ctx,
		`
select id::text, owner_user_id::text, companion_user_id::text, person_card_id::text, context_label, status, created_at
from public.encounter_sessions
where id = $1
  and (owner_user_id = $2 or companion_user_id = $2)
`,
		sessionID,
		actorUserID,
	).Scan(
		&details.Session.ID,
		&details.Session.OwnerUserID,
		&details.Session.CompanionUserID,
		&details.Session.PersonCardID,
		&details.Session.ContextLabel,
		&details.Session.Status,
		&details.Session.CreatedAt,
	)
	if errors.Is(err, pgx.ErrNoRows) {
		return SessionDetails{}, errors.New("encounter session not found")
	}
	if err != nil {
		return SessionDetails{}, fmt.Errorf("load encounter session: %w", err)
	}

	rows, err := repo.pool.Query(
		ctx,
		`
select id::text, session_id::text, sender_user_id::text, body, delivery_mode, created_at
from public.prompt_messages
where session_id = $1
order by created_at asc
`,
		sessionID,
	)
	if err != nil {
		return SessionDetails{}, fmt.Errorf("load prompt messages: %w", err)
	}
	defer rows.Close()

	for rows.Next() {
		var prompt PromptMessage
		if err := rows.Scan(
			&prompt.ID,
			&prompt.SessionID,
			&prompt.SenderUserID,
			&prompt.Body,
			&prompt.DeliveryMode,
			&prompt.CreatedAt,
		); err != nil {
			return SessionDetails{}, fmt.Errorf("scan prompt message: %w", err)
		}
		details.Prompts = append(details.Prompts, prompt)
	}

	if err := rows.Err(); err != nil {
		return SessionDetails{}, fmt.Errorf("iterate prompt messages: %w", err)
	}

	return details, nil
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
