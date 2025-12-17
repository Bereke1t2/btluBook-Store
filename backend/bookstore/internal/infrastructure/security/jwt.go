package security

import (
	"fmt"
	"log"
	"os"
	"time"
	"strings"

	"github.com/dgrijalva/jwt-go"
)

var jwtKey = []byte(os.Getenv("JWT_SECRET"))

type JWTClaims struct {
	UserID   int `json:"user_id"`	
	jwt.StandardClaims
}

func GenerateJWT(userID int) (string, error) {
	expirationTime := time.Now().Add(24 * time.Hour)
	claims := &JWTClaims{
		UserID: userID,
		StandardClaims: jwt.StandardClaims{
			ExpiresAt: expirationTime.Unix(),
		},
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(jwtKey)
}
func ValidateJWT(tokenStr string) (*JWTClaims, error) {
	claims := &JWTClaims{}

	// Remove optional "Bearer " prefix (case-insensitive) and trim spaces
	tokenStr = strings.TrimSpace(tokenStr)
	if len(tokenStr) > 7 && strings.EqualFold(tokenStr[:7], "Bearer ") {
		tokenStr = strings.TrimSpace(tokenStr[7:])
	}

	// Parse the JWT token and validate its signature
	token, err := jwt.ParseWithClaims(tokenStr, claims, func(token *jwt.Token) (any, error) {
		// Ensure the token uses the correct signing method (HS256 in this case)
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return jwtKey, nil
	})

	// If there is an error during parsing, log the error and return
	if err != nil {
		log.Printf("Error parsing token: %v", err)
		return nil, err
	}

	
	log.Println("Token parsed successfully")

	if !token.Valid {
		log.Println("Invalid token signature")
		return nil, jwt.ErrSignatureInvalid
	}

	log.Println("Token is valid")
	return claims, nil
}