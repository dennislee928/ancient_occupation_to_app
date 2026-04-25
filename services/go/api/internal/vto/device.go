package vto

type DeviceRegistration struct {
	ID           string  `json:"id"`
	UserID       string  `json:"user_id"`
	Platform     string  `json:"platform"`
	PushProvider string  `json:"push_provider"`
	PushToken    string  `json:"push_token"`
	AppVersion   *string `json:"app_version,omitempty"`
	LastSeenAt   string  `json:"last_seen_at"`
	CreatedAt    string  `json:"created_at"`
	UpdatedAt    string  `json:"updated_at"`
}
