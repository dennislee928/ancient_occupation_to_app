package vto

type PersonCard struct {
	ID          string  `json:"id"`
	OwnerUserID string  `json:"owner_user_id"`
	Name        string  `json:"name"`
	Affiliation *string `json:"affiliation,omitempty"`
	Notes       *string `json:"notes,omitempty"`
	CreatedAt   string  `json:"created_at"`
	UpdatedAt   string  `json:"updated_at"`
}

type PromptMessage struct {
	ID           string `json:"id"`
	SessionID    string `json:"session_id"`
	SenderUserID string `json:"sender_user_id"`
	Body         string `json:"body"`
	DeliveryMode string `json:"delivery_mode"`
	CreatedAt    string `json:"created_at"`
}

type EncounterSession struct {
	ID              string          `json:"id"`
	OwnerUserID     string          `json:"owner_user_id"`
	CompanionUserID *string         `json:"companion_user_id,omitempty"`
	PersonCardID    string          `json:"person_card_id"`
	ContextLabel    *string         `json:"context_label,omitempty"`
	Status          string          `json:"status"`
	CreatedAt       string          `json:"created_at"`
	Prompts         []PromptMessage `json:"prompts,omitempty"`
}
