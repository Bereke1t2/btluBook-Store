package router

import (
	"github.com/bereke1t2/bookstore/internal/infrastructure/server/handlers"
	"github.com/bereke1t2/bookstore/internal/infrastructure/middleware"
	"github.com/gin-gonic/gin"
)

func RegisterUserRoutes(r *gin.Engine, userHandler *handlers.UserHandler) {
	// Grouping routes under "/users" allows for cleaner code
	// and easy application of middleware specific to users if needed later.
	users := r.Group("/users")
	users.Use(middleware.AuthMiddleware)
	{
		users.GET("", userHandler.GetAllUsers)
		users.GET("/:id", userHandler.GetUserByID)
		users.PUT("/:id", userHandler.UpdateUser)
		users.DELETE("/:id", userHandler.DeleteUser)
	}
}