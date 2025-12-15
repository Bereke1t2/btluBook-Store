package book

import (
	"github.com/bereke1t2/bookstore/internal/domain/book"
)

type GetBookByID struct {
	repo book.BookRepository
}

func NewGetBookByIDUseCase(repo book.BookRepository) *GetBookByID {
	return &GetBookByID{repo: repo}
}

func (uc *GetBookByID) Execute(id string) (*book.Book, error) {
	foundBook, err := uc.repo.GetBookByID(id)
	if err != nil {
		return nil, err
	}
	return foundBook, nil
}