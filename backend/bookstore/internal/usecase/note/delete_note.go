package note

import (
	"github.com/bereke1t2/bookstore/internal/domain/note"
)

type DeleteNoteUseCase struct {
	repo note.NoteRepository
}

func NewDeleteNoteUseCase(repo note.NoteRepository) *DeleteNoteUseCase {
	return &DeleteNoteUseCase{repo: repo}
}

func (uc *DeleteNoteUseCase) Execute(noteID string, userID int) error {
	return uc.repo.Delete(noteID, userID)
}
