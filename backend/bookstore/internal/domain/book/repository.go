package book


type BookRepository interface{
	CreateBook(book *Book) (*Book, error)
	GetBookByID(id string) (*Book, error)
	UpdateBook(book *Book) (*Book, error)
	DeleteBook(id string) error
	GetAllBooks() ([]*Book, error)
}
