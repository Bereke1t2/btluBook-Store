package book

import (
	"github.com/bereke1t2/bookstore/internal/domain/book"
)

type DeleteBook struct {
	repo book.BookRepository
}

func NewDeleteBookUsecase(repo book.BookRepository) *DeleteBook {
	return &DeleteBook{repo: repo}
}
func (uc *DeleteBook) Execute(id string) error {
	err := uc.repo.DeleteBook(id)
	if err != nil {
		return err
	}
	
	return nil
}