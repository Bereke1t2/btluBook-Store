package note

import (
	"github.com/bereke1t2/bookstore/internal/domain/note"
)

type CreateNoteUseCase struct {
	repo note.NoteRepository
}

func NewCreateNoteUseCase(repo note.NoteRepository) *CreateNoteUseCase {
	return &CreateNoteUseCase{repo: repo}
}

func (uc *CreateNoteUseCase) Execute(n *note.Note) (*note.Note, error) {
	return uc.repo.Create(n)
}
