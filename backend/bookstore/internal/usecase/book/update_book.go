package book

import (
	"github.com/bereke1t2/bookstore/internal/domain/book"
)
type UpdateBook struct {
	repo book.BookRepository
}

func NewUpdateBookUseCase(repo book.BookRepository) *UpdateBook {
	return &UpdateBook{repo: repo}
}

func (uc *UpdateBook) Execute(id string, updatedBook *book.Book) (*book.Book, error) {
	foundBook, err := uc.repo.GetBookByID(id)
	if err != nil {
		return nil, err
	}
	return foundBook, nil
}