package dto

type CreatePersonCardRequest struct {
	Name        string  `json:"name"`
	Affiliation *string `json:"affiliation"`
	Notes       *string `json:"notes"`
}

type CreateEncounterSessionRequest struct {
	PersonCardID  string  `json:"person_card_id"`
	ContextLabel  *string `json:"context_label"`
	CompanionUser *string `json:"companion_user_id"`
}

type CreatePromptMessageRequest struct {
	Body         string `json:"body"`
	DeliveryMode string `json:"delivery_mode"`
}
