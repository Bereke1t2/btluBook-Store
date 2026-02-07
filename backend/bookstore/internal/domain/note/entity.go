package note

import "time"

// Note represents a user's note on a specific book.
type Note struct {
	ID            string    `json:"id"`
	UserID        int       `json:"user_id"`
	BookID        string    `json:"book_id"`
	Content       string    `json:"content"`
	IsAIGenerated bool      `json:"is_ai_generated"`
	CreatedAt     time.Time `json:"created_at"`
}

// NewNote creates a new Note instance.
func NewNote(id string, userID int, bookID, content string, isAIGenerated bool, createdAt time.Time) *Note {
	if createdAt.IsZero() {
		createdAt = time.Now()
	}
	return &Note{
		ID:            id,
		UserID:        userID,
		BookID:        bookID,
		Content:       content,
		IsAIGenerated: isAIGenerated,
		CreatedAt:     createdAt,
	}
}
