package router

import (
	"github.com/bereke1t2/bookstore/internal/infrastructure/middleware"
	"github.com/bereke1t2/bookstore/internal/infrastructure/server/handlers"
	"github.com/gin-gonic/gin"
)

func RegisterNoteRoutes(r *gin.Engine, noteHandler *handlers.NoteHandler) {
	notes := r.Group("/notes")
	notes.Use(middleware.AuthMiddleware)

	notes.POST("", noteHandler.CreateNote)
	notes.POST("/ai", noteHandler.GenerateAINote)
	notes.GET("/:book_id", noteHandler.GetNotes)
	notes.DELETE("/:note_id", noteHandler.DeleteNote)
}
