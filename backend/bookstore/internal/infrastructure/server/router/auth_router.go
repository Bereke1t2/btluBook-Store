package router
import (
	"github.com/bereke1t2/bookstore/internal/infrastructure/server/handlers"
	"github.com/gin-gonic/gin"
)

func RegisterAuthRoutes(r *gin.Engine, userHandler *handlers.UserHandler) {
	// Grouping routes under "/auth" allows for cleaner code
	// and easy application of middleware specific to auth if needed later.
	auth := r.Group("/auth")
	{
		auth.POST("/login", userHandler.LoginUser)
		auth.POST("/signup", userHandler.CreateUser)
		
	}
	
}