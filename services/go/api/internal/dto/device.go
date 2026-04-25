package dto

type RegisterDeviceRequest struct {
	Platform     string  `json:"platform"`
	PushToken    string  `json:"push_token"`
	PushProvider string  `json:"push_provider"`
	AppVersion   *string `json:"app_version"`
}
