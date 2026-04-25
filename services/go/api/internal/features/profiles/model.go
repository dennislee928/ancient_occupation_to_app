package profiles

import "time"

type Profile struct {
	ID          string
	UserID      string
	DisplayName *string
	AvatarURL   *string
	CreatedAt   time.Time
	UpdatedAt   time.Time
}
