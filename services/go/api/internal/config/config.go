package config

import (
	"os"
	"strings"
)

type Config struct {
	AppEnv            string
	Port              string
	LogLevel          string
	DatabaseURL       string
	SupabaseURL       string
	SupabaseAPIKey    string
	SupabaseJWTSecret string
}

func Load() Config {
	return Config{
		AppEnv:            envOrDefault("APP_ENV", "development"),
		Port:              envOrDefault("API_PORT", "8080"),
		LogLevel:          envOrDefault("LOG_LEVEL", "info"),
		DatabaseURL:       os.Getenv("SUPABASE_DATABASE_URL"),
		SupabaseURL:       strings.TrimRight(strings.TrimSpace(os.Getenv("SUPABASE_URL")), "/"),
		SupabaseAPIKey:    os.Getenv("SUPABASE_API_KEY"),
		SupabaseJWTSecret: os.Getenv("SUPABASE_JWT_SECRET"),
	}
}

func envOrDefault(key, fallback string) string {
	value := os.Getenv(key)
	if value == "" {
		return fallback
	}

	return value
}
