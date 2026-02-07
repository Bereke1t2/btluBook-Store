package postgres

import (
	"database/sql"
	"time"

	"github.com/bereke1t2/bookstore/internal/domain/note"
	"github.com/google/uuid"
)

type NoteRepositoryPostgres struct {
	db *sql.DB
}

func NewNoteRepositoryPostgres(db *sql.DB) *NoteRepositoryPostgres {
	return &NoteRepositoryPostgres{db: db}
}

// CreateNoteTable creates the notes table if it doesn't exist.
func (r *NoteRepositoryPostgres) CreateNoteTable() error {
	query := `
		CREATE TABLE IF NOT EXISTS notes (
			id VARCHAR(36) PRIMARY KEY,
			user_id INTEGER NOT NULL,
			book_id VARCHAR(36) NOT NULL,
			content TEXT NOT NULL,
			is_ai_generated BOOLEAN DEFAULT FALSE,
			created_at TIMESTAMPTZ DEFAULT NOW()
		);
		CREATE INDEX IF NOT EXISTS idx_notes_user_book ON notes(user_id, book_id);
	`
	_, err := r.db.Exec(query)
	return err
}

// Create inserts a new note into the database.
func (r *NoteRepositoryPostgres) Create(n *note.Note) (*note.Note, error) {
	if n.ID == "" {
		n.ID = uuid.New().String()
	}
	if n.CreatedAt.IsZero() {
		n.CreatedAt = time.Now()
	}

	query := `
		INSERT INTO notes (id, user_id, book_id, content, is_ai_generated, created_at)
		VALUES ($1, $2, $3, $4, $5, $6)
		RETURNING id, user_id, book_id, content, is_ai_generated, created_at
	`
	row := r.db.QueryRow(query, n.ID, n.UserID, n.BookID, n.Content, n.IsAIGenerated, n.CreatedAt)

	var created note.Note
	err := row.Scan(&created.ID, &created.UserID, &created.BookID, &created.Content, &created.IsAIGenerated, &created.CreatedAt)
	if err != nil {
		return nil, err
	}
	return &created, nil
}

// GetByBookID retrieves all notes for a specific book and user.
func (r *NoteRepositoryPostgres) GetByBookID(bookID string, userID int) ([]*note.Note, error) {
	query := `
		SELECT id, user_id, book_id, content, is_ai_generated, created_at
		FROM notes
		WHERE book_id = $1 AND user_id = $2
		ORDER BY created_at DESC
	`
	rows, err := r.db.Query(query, bookID, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var notes []*note.Note
	for rows.Next() {
		var n note.Note
		if err := rows.Scan(&n.ID, &n.UserID, &n.BookID, &n.Content, &n.IsAIGenerated, &n.CreatedAt); err != nil {
			return nil, err
		}
		notes = append(notes, &n)
	}
	return notes, nil
}

// Delete removes a note by ID for a specific user.
func (r *NoteRepositoryPostgres) Delete(noteID string, userID int) error {
	query := `DELETE FROM notes WHERE id = $1 AND user_id = $2`
	_, err := r.db.Exec(query, noteID, userID)
	return err
}
