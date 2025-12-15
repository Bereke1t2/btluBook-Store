package book


import (
	"github.com/bereke1t2/bookstore/internal/domain/book"
)
type GetAllBooks struct {
	repo book.BookRepository
}
func NewGetAllBooksUseCase(repo book.BookRepository) *GetAllBooks {
	return &GetAllBooks{repo: repo}
}

func (uc *GetAllBooks) Execute() ([]*book.Book, error) {
	print("Executing Get All Books Use Case")
	books, err := uc.repo.GetAllBooks()
	if  err != nil {
		return nil, err
	}
	print("Get AAll books Use case executed")
	return books, nil
}