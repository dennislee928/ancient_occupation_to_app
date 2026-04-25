package config

import "os"

type Config struct {
	AppEnv      string
	Port        string
	LogLevel    string
	DatabaseURL string
}

func Load() Config {
	return Config{
		AppEnv:      envOrDefault("APP_ENV", "development"),
		Port:        envOrDefault("API_PORT", "8080"),
		LogLevel:    envOrDefault("LOG_LEVEL", "info"),
		DatabaseURL: os.Getenv("SUPABASE_DATABASE_URL"),
	}
}

func envOrDefault(key, fallback string) string {
	value := os.Getenv(key)
	if value == "" {
		return fallback
	}

	return value
}
