package middleware

import (
	"context"
	"net/http"

	"github.com/bereke1t2/bookstore/internal/infrastructure/security"
	"github.com/gin-gonic/gin"
)

func AuthMiddleware(c *gin.Context) {
	token := c.GetHeader("Authorization")
	if token == "" {
		c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	claims, err := security.ValidateJWT(token)
	if err != nil {
		c.AbortWithStatusJSON(http.StatusForbidden, gin.H{"error": "Forbidden"})
		return
	}

	// 1. Set the variable in Gin context (accessible in handlers via c.Get("userID"))
	c.Set("userID", claims.UserID)

	// 2. Update the standard request context (accessible in UseCases via ctx.Value("userID"))
	// This ensures your Clean Architecture layers receiving c.Request.Context() still work.
	ctx := context.WithValue(c.Request.Context(), "userID", claims.UserID)
	c.Request = c.Request.WithContext(ctx)

	c.Next()
}