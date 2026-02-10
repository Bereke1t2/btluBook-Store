package router

import (
	"github.com/bereke1t2/bookstore/internal/infrastructure/middleware"
	"github.com/bereke1t2/bookstore/internal/infrastructure/server/handlers"
	"github.com/gin-gonic/gin"
)

func RegisterBookRoutes(r *gin.Engine, bookHandler *handlers.BookHandler) {
	// Create a route group for "/books"
	books := r.Group("/books")

	// Apply the middleware to this group
	// Ensure AuthMiddleware is compatible with func(*gin.Context)
	books.Use(middleware.AuthMiddleware)

	// Define routes
	// Note: Gin uses ":id" for path parameters, not "{id}"
	books.GET("/trending", bookHandler.GetTrendingBooks) // Add this before :id to avoid conflict
	books.POST("", bookHandler.CreateBook)
	books.GET("", bookHandler.GetAllBooks)
	books.GET("/:id", bookHandler.GetBookByID)
	books.PUT("/:id", bookHandler.UpdateBook)
	books.DELETE("/:id", bookHandler.DeleteBook)
	books.POST("/upload", bookHandler.CreateBook)
}
