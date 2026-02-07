package router

import (
	"github.com/bereke1t2/bookstore/internal/infrastructure/server/handlers"
	"github.com/gin-gonic/gin"
)

func SetupRoutes(r *gin.Engine, bookHandler *handlers.BookHandler, userHandler *handlers.UserHandler, chatRouter *handlers.ChatHandler, noteHandler *handlers.NoteHandler) {
	// Serve static files from uploads directory
	r.Static("/uploads", "./uploads")

	RegisterBookRoutes(r, bookHandler)
	RegisterUserRoutes(r, userHandler)
	RegisterAuthRoutes(r, userHandler)
	RegisterChatRoutes(r, chatRouter)
	RegisterNoteRoutes(r, noteHandler)
}
