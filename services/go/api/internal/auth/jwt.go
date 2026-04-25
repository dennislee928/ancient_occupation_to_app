package auth

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"strings"
	"time"
)

type jwtClaims struct {
	Sub string `json:"sub"`
	Exp int64  `json:"exp"`
}

func VerifyHS256Token(token, secret string) (User, error) {
	parts := strings.Split(token, ".")
	if len(parts) != 3 {
		return User{}, errors.New("invalid bearer token format")
	}

	headerBytes, err := decodeBase64URL(parts[0])
	if err != nil {
		return User{}, fmt.Errorf("decode jwt header: %w", err)
	}

	var header struct {
		Alg string `json:"alg"`
		Typ string `json:"typ"`
	}
	if err := json.Unmarshal(headerBytes, &header); err != nil {
		return User{}, fmt.Errorf("parse jwt header: %w", err)
	}

	if header.Alg != "HS256" {
		return User{}, fmt.Errorf("unsupported jwt alg: %s", header.Alg)
	}

	mac := hmac.New(sha256.New, []byte(secret))
	mac.Write([]byte(parts[0] + "." + parts[1]))
	expected := mac.Sum(nil)

	signature, err := decodeBase64URL(parts[2])
	if err != nil {
		return User{}, fmt.Errorf("decode jwt signature: %w", err)
	}

	if !hmac.Equal(signature, expected) {
		return User{}, errors.New("invalid jwt signature")
	}

	payloadBytes, err := decodeBase64URL(parts[1])
	if err != nil {
		return User{}, fmt.Errorf("decode jwt payload: %w", err)
	}

	var claims jwtClaims
	if err := json.Unmarshal(payloadBytes, &claims); err != nil {
		return User{}, fmt.Errorf("parse jwt payload: %w", err)
	}

	if claims.Sub == "" {
		return User{}, errors.New("jwt sub claim is required")
	}

	if claims.Exp > 0 && time.Now().Unix() >= claims.Exp {
		return User{}, errors.New("jwt token is expired")
	}

	return User{ID: claims.Sub}, nil
}

func decodeBase64URL(input string) ([]byte, error) {
	return base64.RawURLEncoding.DecodeString(input)
}
