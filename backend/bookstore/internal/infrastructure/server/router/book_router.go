package router

import (
	"github.com/gin-gonic/gin"
	"github.com/bereke1t2/bookstore/internal/infrastructure/middleware"
	"github.com/bereke1t2/bookstore/internal/infrastructure/server/handlers"
)

func RegisterBookRoutes(r *gin.Engine, bookHandler *handlers.BookHandler) {
	// Create a route group for "/books"
	books := r.Group("/books")
	
	// Apply the middleware to this group
	// Ensure AuthMiddleware is compatible with func(*gin.Context)
	books.Use(middleware.AuthMiddleware)

	// Define routes
	// Note: Gin uses ":id" for path parameters, not "{id}"
	books.POST("", bookHandler.CreateBook)
	books.GET("", bookHandler.GetAllBooks)
	books.GET("/:id", bookHandler.GetBookByID)
	books.PUT("/:id", bookHandler.UpdateBook)
	books.DELETE("/:id", bookHandler.DeleteBook)
	books.POST("/upload", bookHandler.CreateBook)
}