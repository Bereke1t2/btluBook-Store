package note

// NoteRepository defines methods for note persistence.
type NoteRepository interface {
	Create(note *Note) (*Note, error)
	GetByBookID(bookID string, userID int) ([]*Note, error)
	Delete(noteID string, userID int) error
}
