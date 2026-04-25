package http

import (
	"crypto/sha256"
	"encoding/hex"

	"ancient_occupation_to_app/services/go/api/internal/features/devices"
	"ancient_occupation_to_app/services/go/api/internal/features/nomenclator"
	"ancient_occupation_to_app/services/go/api/internal/features/profiles"
	"ancient_occupation_to_app/services/go/api/internal/vto"
)

func mapProfile(profile profiles.Profile) vto.Profile {
	return vto.Profile{
		ID:          profile.ID,
		UserID:      profile.UserID,
		DisplayName: profile.DisplayName,
		AvatarURL:   profile.AvatarURL,
		CreatedAt:   profile.CreatedAt.UTC().Format(timestampLayout),
		UpdatedAt:   profile.UpdatedAt.UTC().Format(timestampLayout),
	}
}

func mapDeviceRegistration(registration devices.Registration) vto.DeviceRegistration {
	return vto.DeviceRegistration{
		ID:           registration.ID,
		UserID:       registration.UserID,
		Platform:     registration.Platform,
		PushProvider: registration.PushProvider,
		PushToken:    maskToken(registration.PushToken),
		AppVersion:   registration.AppVersion,
		LastSeenAt:   registration.LastSeenAt.UTC().Format(timestampLayout),
		CreatedAt:    registration.CreatedAt.UTC().Format(timestampLayout),
		UpdatedAt:    registration.UpdatedAt.UTC().Format(timestampLayout),
	}
}

func mapPersonCard(card nomenclator.PersonCard) vto.PersonCard {
	return vto.PersonCard{
		ID:          card.ID,
		OwnerUserID: card.OwnerUserID,
		Name:        card.Name,
		Affiliation: card.Affiliation,
		Notes:       card.Notes,
		CreatedAt:   card.CreatedAt.UTC().Format(timestampLayout),
		UpdatedAt:   card.UpdatedAt.UTC().Format(timestampLayout),
	}
}

func mapPrompt(prompt nomenclator.PromptMessage) vto.PromptMessage {
	return vto.PromptMessage{
		ID:           prompt.ID,
		SessionID:    prompt.SessionID,
		SenderUserID: prompt.SenderUserID,
		Body:         prompt.Body,
		DeliveryMode: prompt.DeliveryMode,
		CreatedAt:    prompt.CreatedAt.UTC().Format(timestampLayout),
	}
}

func mapEncounterSession(session nomenclator.EncounterSession, prompts []nomenclator.PromptMessage) vto.EncounterSession {
	response := vto.EncounterSession{
		ID:              session.ID,
		OwnerUserID:     session.OwnerUserID,
		CompanionUserID: session.CompanionUserID,
		PersonCardID:    session.PersonCardID,
		ContextLabel:    session.ContextLabel,
		Status:          session.Status,
		CreatedAt:       session.CreatedAt.UTC().Format(timestampLayout),
	}

	if len(prompts) > 0 {
		response.Prompts = make([]vto.PromptMessage, 0, len(prompts))
		for _, prompt := range prompts {
			response.Prompts = append(response.Prompts, mapPrompt(prompt))
		}
	}

	return response
}

func maskToken(token string) string {
	if len(token) <= 8 {
		return token
	}

	sum := sha256.Sum256([]byte(token))
	return token[:4] + "..." + hex.EncodeToString(sum[:])[:12]
}

const timestampLayout = "2006-01-02T15:04:05Z07:00"
