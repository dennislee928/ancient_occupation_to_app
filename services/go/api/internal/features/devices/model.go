package devices

import "time"

type Registration struct {
	ID           string
	UserID       string
	Platform     string
	PushToken    string
	PushProvider string
	AppVersion   *string
	LastSeenAt   time.Time
	CreatedAt    time.Time
	UpdatedAt    time.Time
}
