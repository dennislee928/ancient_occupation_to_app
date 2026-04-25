package auth

import (
	"context"
	"crypto"
	"crypto/ecdsa"
	"crypto/ed25519"
	"crypto/elliptic"
	"crypto/hmac"
	"crypto/rsa"
	"crypto/sha256"
	"crypto/sha512"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"hash"
	"math/big"
	"net/http"
	"strings"
	"sync"
	"time"
)

const jwksCacheTTL = 10 * time.Minute

type Verifier struct {
	supabaseURL       string
	supabaseAPIKey    string
	supabaseJWTSecret string
	httpClient        *http.Client

	mu         sync.RWMutex
	cachedJWKS cachedJWKS
}

type cachedJWKS struct {
	keys      []jwk
	expiresAt time.Time
}

type jwtHeader struct {
	Alg string `json:"alg"`
	Kid string `json:"kid"`
	Typ string `json:"typ"`
}

type jwtClaims struct {
	Sub string `json:"sub"`
	Exp int64  `json:"exp"`
	Iss string `json:"iss"`
}

type jwtParts struct {
	header       jwtHeader
	claims       jwtClaims
	signingInput string
	signature    []byte
}

type jwksResponse struct {
	Keys []jwk `json:"keys"`
}

type jwk struct {
	Kid string `json:"kid"`
	Alg string `json:"alg"`
	Kty string `json:"kty"`
	Use string `json:"use"`
	N   string `json:"n"`
	E   string `json:"e"`
	Crv string `json:"crv"`
	X   string `json:"x"`
	Y   string `json:"y"`
}

func NewVerifier(supabaseURL, supabaseAPIKey, supabaseJWTSecret string) *Verifier {
	return &Verifier{
		supabaseURL:       strings.TrimRight(strings.TrimSpace(supabaseURL), "/"),
		supabaseAPIKey:    strings.TrimSpace(supabaseAPIKey),
		supabaseJWTSecret: strings.TrimSpace(supabaseJWTSecret),
		httpClient: &http.Client{
			Timeout: 10 * time.Second,
		},
	}
}

func (v *Verifier) Verify(ctx context.Context, token string) (User, error) {
	parts, err := parseJWT(token)
	if err != nil {
		return User{}, err
	}

	if err := validateClaims(parts.claims, v.expectedIssuer()); err != nil {
		return User{}, err
	}

	if v.supabaseURL != "" {
		if err := v.verifyWithJWKS(ctx, parts); err == nil {
			return User{ID: parts.claims.Sub}, nil
		}
	}

	if v.supabaseURL != "" && v.supabaseAPIKey != "" {
		user, err := v.verifyWithAuthServer(ctx, token, parts.claims)
		if err == nil {
			return user, nil
		}
	}

	if v.supabaseJWTSecret != "" && parts.header.Alg == "HS256" {
		return verifyHS256Token(token, v.supabaseJWTSecret, v.expectedIssuer())
	}

	return User{}, errors.New("unable to verify bearer token with Supabase JWKS or Auth server")
}

func verifyHS256Token(token, secret, expectedIssuer string) (User, error) {
	parts, err := parseJWT(token)
	if err != nil {
		return User{}, err
	}

	if parts.header.Alg != "HS256" {
		return User{}, fmt.Errorf("unsupported jwt alg: %s", parts.header.Alg)
	}

	mac := hmac.New(sha256.New, []byte(secret))
	mac.Write([]byte(parts.signingInput))
	expectedSignature := mac.Sum(nil)
	if !hmac.Equal(parts.signature, expectedSignature) {
		return User{}, errors.New("invalid jwt signature")
	}

	if err := validateClaims(parts.claims, expectedIssuer); err != nil {
		return User{}, err
	}

	return User{ID: parts.claims.Sub}, nil
}

func (v *Verifier) verifyWithJWKS(ctx context.Context, parts jwtParts) error {
	keys, err := v.getJWKS(ctx, false)
	if err != nil {
		return err
	}

	if err := verifyJWTSignatureWithJWKS(parts, keys); err == nil {
		return nil
	}

	keys, err = v.getJWKS(ctx, true)
	if err != nil {
		return err
	}

	return verifyJWTSignatureWithJWKS(parts, keys)
}

func (v *Verifier) verifyWithAuthServer(ctx context.Context, token string, claims jwtClaims) (User, error) {
	request, err := http.NewRequestWithContext(ctx, http.MethodGet, v.supabaseURL+"/auth/v1/user", nil)
	if err != nil {
		return User{}, fmt.Errorf("build auth verification request: %w", err)
	}

	request.Header.Set("apikey", v.supabaseAPIKey)
	request.Header.Set("Authorization", "Bearer "+token)

	response, err := v.httpClient.Do(request)
	if err != nil {
		return User{}, fmt.Errorf("verify token with Supabase Auth server: %w", err)
	}
	defer response.Body.Close()

	if response.StatusCode != http.StatusOK {
		return User{}, fmt.Errorf("supabase auth verification failed with status %d", response.StatusCode)
	}

	var payload struct {
		ID string `json:"id"`
	}
	if err := json.NewDecoder(response.Body).Decode(&payload); err != nil {
		return User{}, fmt.Errorf("decode auth user response: %w", err)
	}

	if payload.ID != "" {
		return User{ID: payload.ID}, nil
	}

	return User{ID: claims.Sub}, nil
}

func (v *Verifier) getJWKS(ctx context.Context, forceRefresh bool) ([]jwk, error) {
	if !forceRefresh {
		v.mu.RLock()
		cached := v.cachedJWKS
		v.mu.RUnlock()
		if len(cached.keys) > 0 && time.Now().Before(cached.expiresAt) {
			return cached.keys, nil
		}
	}

	request, err := http.NewRequestWithContext(ctx, http.MethodGet, v.supabaseURL+"/auth/v1/.well-known/jwks.json", nil)
	if err != nil {
		return nil, fmt.Errorf("build jwks request: %w", err)
	}

	response, err := v.httpClient.Do(request)
	if err != nil {
		return nil, fmt.Errorf("fetch supabase jwks: %w", err)
	}
	defer response.Body.Close()

	if response.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("fetch supabase jwks returned status %d", response.StatusCode)
	}

	var jwks jwksResponse
	if err := json.NewDecoder(response.Body).Decode(&jwks); err != nil {
		return nil, fmt.Errorf("decode supabase jwks: %w", err)
	}

	v.mu.Lock()
	v.cachedJWKS = cachedJWKS{
		keys:      jwks.Keys,
		expiresAt: time.Now().Add(jwksCacheTTL),
	}
	v.mu.Unlock()

	return jwks.Keys, nil
}

func verifyJWTSignatureWithJWKS(parts jwtParts, keys []jwk) error {
	if len(keys) == 0 {
		return errors.New("supabase jwks response was empty")
	}

	var candidateKeys []jwk
	for _, key := range keys {
		if parts.header.Kid != "" && key.Kid != parts.header.Kid {
			continue
		}
		if key.Alg != "" && key.Alg != parts.header.Alg {
			continue
		}
		candidateKeys = append(candidateKeys, key)
	}

	if len(candidateKeys) == 0 {
		return fmt.Errorf("no jwk matched kid=%q alg=%q", parts.header.Kid, parts.header.Alg)
	}

	var lastErr error
	for _, key := range candidateKeys {
		publicKey, err := parseJWK(key)
		if err != nil {
			lastErr = err
			continue
		}
		if err := verifySignature(parts.header.Alg, parts.signingInput, parts.signature, publicKey); err == nil {
			return nil
		} else {
			lastErr = err
		}
	}

	if lastErr == nil {
		lastErr = errors.New("jwt signature verification failed")
	}

	return lastErr
}

func verifySignature(alg, signingInput string, signature []byte, publicKey any) error {
	message := []byte(signingInput)

	switch alg {
	case "RS256":
		return verifyRSAPKCS1v15(message, signature, publicKey, crypto.SHA256)
	case "RS384":
		return verifyRSAPKCS1v15(message, signature, publicKey, crypto.SHA384)
	case "RS512":
		return verifyRSAPKCS1v15(message, signature, publicKey, crypto.SHA512)
	case "PS256":
		return verifyRSAPSS(message, signature, publicKey, crypto.SHA256)
	case "PS384":
		return verifyRSAPSS(message, signature, publicKey, crypto.SHA384)
	case "PS512":
		return verifyRSAPSS(message, signature, publicKey, crypto.SHA512)
	case "ES256":
		return verifyECDSA(message, signature, publicKey, crypto.SHA256, 32)
	case "ES384":
		return verifyECDSA(message, signature, publicKey, crypto.SHA384, 48)
	case "ES512":
		return verifyECDSA(message, signature, publicKey, crypto.SHA512, 66)
	case "EdDSA":
		key, ok := publicKey.(ed25519.PublicKey)
		if !ok {
			return errors.New("invalid ed25519 public key")
		}
		if !ed25519.Verify(key, message, signature) {
			return errors.New("invalid ed25519 signature")
		}
		return nil
	default:
		return fmt.Errorf("unsupported jwt alg: %s", alg)
	}
}

func verifyRSAPKCS1v15(message, signature []byte, publicKey any, hashAlgorithm crypto.Hash) error {
	key, ok := publicKey.(*rsa.PublicKey)
	if !ok {
		return errors.New("invalid rsa public key")
	}
	digest := sumHash(hashAlgorithm, message)
	return rsa.VerifyPKCS1v15(key, hashAlgorithm, digest, signature)
}

func verifyRSAPSS(message, signature []byte, publicKey any, hashAlgorithm crypto.Hash) error {
	key, ok := publicKey.(*rsa.PublicKey)
	if !ok {
		return errors.New("invalid rsa public key")
	}
	digest := sumHash(hashAlgorithm, message)
	return rsa.VerifyPSS(key, hashAlgorithm, digest, signature, nil)
}

func verifyECDSA(message, signature []byte, publicKey any, hashAlgorithm crypto.Hash, componentSize int) error {
	key, ok := publicKey.(*ecdsa.PublicKey)
	if !ok {
		return errors.New("invalid ecdsa public key")
	}
	if len(signature) != componentSize*2 {
		return errors.New("invalid ecdsa signature size")
	}

	r := new(big.Int).SetBytes(signature[:componentSize])
	s := new(big.Int).SetBytes(signature[componentSize:])
	digest := sumHash(hashAlgorithm, message)
	if !ecdsa.Verify(key, digest, r, s) {
		return errors.New("invalid ecdsa signature")
	}
	return nil
}

func sumHash(hashAlgorithm crypto.Hash, data []byte) []byte {
	var hasher hash.Hash
	switch hashAlgorithm {
	case crypto.SHA256:
		hasher = sha256.New()
	case crypto.SHA384:
		hasher = sha512.New384()
	case crypto.SHA512:
		hasher = sha512.New()
	default:
		panic("unsupported hash algorithm")
	}
	hasher.Write(data)
	return hasher.Sum(nil)
}

func parseJWK(key jwk) (any, error) {
	switch key.Kty {
	case "RSA":
		return parseRSAKey(key)
	case "EC":
		return parseECKey(key)
	case "OKP":
		return parseOKPKey(key)
	default:
		return nil, fmt.Errorf("unsupported jwk kty: %s", key.Kty)
	}
}

func parseRSAKey(key jwk) (*rsa.PublicKey, error) {
	nBytes, err := decodeBase64URL(key.N)
	if err != nil {
		return nil, fmt.Errorf("decode rsa modulus: %w", err)
	}
	eBytes, err := decodeBase64URL(key.E)
	if err != nil {
		return nil, fmt.Errorf("decode rsa exponent: %w", err)
	}

	exponent := 0
	for _, b := range eBytes {
		exponent = exponent<<8 + int(b)
	}

	return &rsa.PublicKey{
		N: new(big.Int).SetBytes(nBytes),
		E: exponent,
	}, nil
}

func parseECKey(key jwk) (*ecdsa.PublicKey, error) {
	curve, err := curveFromName(key.Crv)
	if err != nil {
		return nil, err
	}

	xBytes, err := decodeBase64URL(key.X)
	if err != nil {
		return nil, fmt.Errorf("decode ec x: %w", err)
	}
	yBytes, err := decodeBase64URL(key.Y)
	if err != nil {
		return nil, fmt.Errorf("decode ec y: %w", err)
	}

	return &ecdsa.PublicKey{
		Curve: curve,
		X:     new(big.Int).SetBytes(xBytes),
		Y:     new(big.Int).SetBytes(yBytes),
	}, nil
}

func parseOKPKey(key jwk) (ed25519.PublicKey, error) {
	if key.Crv != "Ed25519" {
		return nil, fmt.Errorf("unsupported okp curve: %s", key.Crv)
	}

	xBytes, err := decodeBase64URL(key.X)
	if err != nil {
		return nil, fmt.Errorf("decode okp x: %w", err)
	}

	return ed25519.PublicKey(xBytes), nil
}

func curveFromName(name string) (elliptic.Curve, error) {
	switch name {
	case "P-256":
		return elliptic.P256(), nil
	case "P-384":
		return elliptic.P384(), nil
	case "P-521":
		return elliptic.P521(), nil
	default:
		return nil, fmt.Errorf("unsupported ec curve: %s", name)
	}
}

func parseJWT(token string) (jwtParts, error) {
	segments := strings.Split(token, ".")
	if len(segments) != 3 {
		return jwtParts{}, errors.New("invalid bearer token format")
	}

	headerBytes, err := decodeBase64URL(segments[0])
	if err != nil {
		return jwtParts{}, fmt.Errorf("decode jwt header: %w", err)
	}

	var header jwtHeader
	if err := json.Unmarshal(headerBytes, &header); err != nil {
		return jwtParts{}, fmt.Errorf("parse jwt header: %w", err)
	}

	payloadBytes, err := decodeBase64URL(segments[1])
	if err != nil {
		return jwtParts{}, fmt.Errorf("decode jwt payload: %w", err)
	}

	var claims jwtClaims
	if err := json.Unmarshal(payloadBytes, &claims); err != nil {
		return jwtParts{}, fmt.Errorf("parse jwt payload: %w", err)
	}

	signature, err := decodeBase64URL(segments[2])
	if err != nil {
		return jwtParts{}, fmt.Errorf("decode jwt signature: %w", err)
	}

	return jwtParts{
		header:       header,
		claims:       claims,
		signingInput: segments[0] + "." + segments[1],
		signature:    signature,
	}, nil
}

func validateClaims(claims jwtClaims, expectedIssuer string) error {
	if claims.Sub == "" {
		return errors.New("jwt sub claim is required")
	}
	if claims.Exp > 0 && time.Now().Unix() >= claims.Exp {
		return errors.New("jwt token is expired")
	}
	if expectedIssuer != "" && claims.Iss != "" && claims.Iss != expectedIssuer {
		return fmt.Errorf("unexpected jwt issuer: %s", claims.Iss)
	}
	return nil
}

func (v *Verifier) expectedIssuer() string {
	if v.supabaseURL == "" {
		return ""
	}
	return v.supabaseURL + "/auth/v1"
}

func decodeBase64URL(input string) ([]byte, error) {
	return base64.RawURLEncoding.DecodeString(input)
}
