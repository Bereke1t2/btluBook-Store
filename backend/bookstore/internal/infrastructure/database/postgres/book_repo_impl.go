package postgres

import (
	"database/sql"
	"github.com/bereke1t2/bookstore/internal/domain/book"
)

var _ book.BookRepository = (*BookRepositoryImpl)(nil)

type BookRepositoryImpl struct {
	db *sql.DB
}

func NewBookRepositoryImpl(db *sql.DB) *BookRepositoryImpl {
	return &BookRepositoryImpl{db: db}
}

func (r *BookRepositoryImpl) DeleteBook(id string) error {
	query := "DELETE FROM books WHERE id = $1"
	_, err := r.db.Exec(query, id)
	if err != nil {
		return err
	}
	return nil
}

func (r *BookRepositoryImpl) CreateBook(book *book.Book) (*book.Book, error) {
	print("creating book in repo")
	print("with book url: ", book.BookURL)
	print("with image url: ", book.CoverUrl)
	query := "INSERT INTO books (title, author, price, rating , category, is_featured, shared_by, tag, cover_url , book_url) VALUES ( $1, $2, $3, $4, $5, $6, $7, $8, $9 , $10)"
	_, err := r.db.Exec(query, book.Title, book.Author, book.Price, book.Rating, book.Category, book.IsFeatured, book.SharedBy, book.Tag, book.CoverUrl, book.BookURL)
	if err != nil {
		print("error creating book in repo: ", err.Error())
		return nil, err
	}
	print("book created in repo")
	print("with book url: ", book.BookURL)
	print("with image url: ", book.CoverUrl)
	return book, nil
}
func (r *BookRepositoryImpl) GetBookByID(id string) (*book.Book, error) {
	query := "SELECT id, title, author, price, rating , category , is_featured , shared_by , tag ,cover_url, book_url FROM books WHERE id = $1"
	row := r.db.QueryRow(query, id)
	print("fetching book by id in repo: ", id)
	var b book.Book
	if err := row.Scan(&b.ID, &b.Title, &b.Author, &b.Price, &b.Rating, &b.Category, &b.IsFeatured, &b.SharedBy, &b.Tag, &b.CoverUrl, &b.BookURL); err != nil {
		if err == sql.ErrNoRows {
			return nil, nil
		}
		return nil, err
	}
	return &b, nil
}
func (r *BookRepositoryImpl) GetAllBooks() ([]*book.Book, error) {
	query := "SELECT id, title, author, price, rating , category , is_featured , shared_by , tag , cover_url , book_url FROM books"
	rows, err := r.db.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var books []*book.Book
	for rows.Next() {
		var b book.Book
		if err := rows.Scan(&b.ID, &b.Title, &b.Author, &b.Price, &b.Rating, &b.Category, &b.IsFeatured, &b.SharedBy, &b.Tag, &b.CoverUrl, &b.BookURL); err != nil {
			return nil, err
		}
		books = append(books, &b)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}
	return books, nil
}
func (r *BookRepositoryImpl) UpdateBook(bk *book.Book) (*book.Book, error) {
	query := "UPDATE books SET title = $1, author = $2, price = $3, rating=$4 , category=$5 , is_featured=$6 , shared_by=$7 , tag=$8 ,  cover_url = $9 WHERE id = $10 RETURNING id, title, author, price, rating, category, is_featured, shared_by, tag, cover_url"
	row := r.db.QueryRow(query, bk.Title, bk.Author, bk.Price, bk.Rating, bk.Category, bk.IsFeatured, bk.SharedBy, bk.Tag, bk.CoverUrl, bk.ID)
	var updated book.Book
	if err := row.Scan(&updated.ID, &updated.Title, &updated.Author, &updated.Price, &updated.Rating, &updated.Category, &updated.IsFeatured, &updated.SharedBy, &updated.Tag, &updated.CoverUrl); err != nil {
		return nil, err
	}
	return &updated, nil
}