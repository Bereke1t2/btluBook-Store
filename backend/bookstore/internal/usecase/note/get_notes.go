package note

import (
	"github.com/bereke1t2/bookstore/internal/domain/note"
)

type GetNotesUseCase struct {
	repo note.NoteRepository
}

func NewGetNotesUseCase(repo note.NoteRepository) *GetNotesUseCase {
	return &GetNotesUseCase{repo: repo}
}

func (uc *GetNotesUseCase) Execute(bookID string, userID int) ([]*note.Note, error) {
	return uc.repo.GetByBookID(bookID, userID)
}
