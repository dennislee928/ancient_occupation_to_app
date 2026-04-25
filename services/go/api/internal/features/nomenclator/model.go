package nomenclator

import "time"

type PersonCard struct {
	ID          string
	OwnerUserID string
	Name        string
	Affiliation *string
	Notes       *string
	CreatedAt   time.Time
	UpdatedAt   time.Time
}

type EncounterSession struct {
	ID              string
	OwnerUserID     string
	CompanionUserID *string
	PersonCardID    string
	ContextLabel    *string
	Status          string
	CreatedAt       time.Time
}

type PromptMessage struct {
	ID           string
	SessionID    string
	SenderUserID string
	Body         string
	DeliveryMode string
	CreatedAt    time.Time
}
