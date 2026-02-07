package handlers

import (
	"net/http"
	"strconv"

	"github.com/bereke1t2/bookstore/internal/domain/note"
	noteuc "github.com/bereke1t2/bookstore/internal/usecase/note"
	"github.com/gin-gonic/gin"
)

type NoteHandler struct {
	createNoteUC     *noteuc.CreateNoteUseCase
	getNotesUC       *noteuc.GetNotesUseCase
	deleteNoteUC     *noteuc.DeleteNoteUseCase
	generateAINoteUC *noteuc.GenerateAINoteUseCase
}

func NewNoteHandler(
	createNoteUC *noteuc.CreateNoteUseCase,
	getNotesUC *noteuc.GetNotesUseCase,
	deleteNoteUC *noteuc.DeleteNoteUseCase,
	generateAINoteUC *noteuc.GenerateAINoteUseCase,
) *NoteHandler {
	return &NoteHandler{
		createNoteUC:     createNoteUC,
		getNotesUC:       getNotesUC,
		deleteNoteUC:     deleteNoteUC,
		generateAINoteUC: generateAINoteUC,
	}
}

// CreateNote handles manual note creation.
// POST /notes
// Body: { "book_id": "...", "content": "..." }
func (h *NoteHandler) CreateNote(c *gin.Context) {
	userID, err := getUserIDFromContext(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	var req struct {
		BookID  string `json:"book_id" binding:"required"`
		Content string `json:"content" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	n := &note.Note{
		UserID:        userID,
		BookID:        req.BookID,
		Content:       req.Content,
		IsAIGenerated: false,
	}

	created, err := h.createNoteUC.Execute(n)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"data": gin.H{"note": created}})
}

// GenerateAINote handles AI-powered note generation.
// POST /notes/ai
// Body: { "book_id": "...", "text": "selected text..." }
func (h *NoteHandler) GenerateAINote(c *gin.Context) {
	userID, err := getUserIDFromContext(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	var req struct {
		BookID string `json:"book_id" binding:"required"`
		Text   string `json:"text" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	created, err := h.generateAINoteUC.Execute(c.Request.Context(), userID, req.BookID, req.Text)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"data": gin.H{"note": created}})
}

// GetNotes retrieves notes for a specific book.
// GET /notes/:book_id
func (h *NoteHandler) GetNotes(c *gin.Context) {
	userID, err := getUserIDFromContext(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	bookID := c.Param("book_id")
	if bookID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "book_id is required"})
		return
	}

	notes, err := h.getNotesUC.Execute(bookID, userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": gin.H{"notes": notes}})
}

// DeleteNote removes a note.
// DELETE /notes/:note_id
func (h *NoteHandler) DeleteNote(c *gin.Context) {
	userID, err := getUserIDFromContext(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	noteID := c.Param("note_id")
	if noteID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "note_id is required"})
		return
	}

	if err := h.deleteNoteUC.Execute(noteID, userID); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.Status(http.StatusNoContent)
}

// Helper to extract user ID from JWT claims set by middleware.
func getUserIDFromContext(c *gin.Context) (int, error) {
	// The middleware should set "user_id" in the context
	userIDRaw, exists := c.Get("user_id")
	if !exists {
		// Try header fallback for testing
		userIDStr := c.GetHeader("X-User-ID")
		if userIDStr != "" {
			return strconv.Atoi(userIDStr)
		}
		return 0, nil
	}
	switch v := userIDRaw.(type) {
	case int:
		return v, nil
	case float64:
		return int(v), nil
	case string:
		return strconv.Atoi(v)
	default:
		return 0, nil
	}
}
