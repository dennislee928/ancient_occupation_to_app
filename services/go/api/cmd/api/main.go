package main

import (
	"context"
	"log"
	"net/http"
	"os/signal"
	"syscall"
	"time"

	"ancient_occupation_to_app/services/go/api/internal/config"
	"ancient_occupation_to_app/services/go/api/internal/database"
	httpserver "ancient_occupation_to_app/services/go/api/internal/http"
)

func main() {
	cfg := config.Load()

	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	pool, err := database.NewPool(ctx, cfg.DatabaseURL)
	if err != nil {
		log.Fatalf("database setup failed: %v", err)
	}
	if pool != nil {
		defer pool.Close()
	}

	server := &http.Server{
		Addr:              ":" + cfg.Port,
		Handler:           httpserver.NewRouter(cfg, pool),
		ReadHeaderTimeout: 5 * time.Second,
	}

	go func() {
		<-ctx.Done()

		shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()

		if err := server.Shutdown(shutdownCtx); err != nil {
			log.Printf("graceful shutdown failed: %v", err)
		}
	}()

	log.Printf("go-api listening on :%s in %s mode", cfg.Port, cfg.AppEnv)

	if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		log.Fatalf("server error: %v", err)
	}
}
