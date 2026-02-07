package book

import (
	"context"

	"github.com/bereke1t2/bookstore/internal/domain/book"
	"github.com/bereke1t2/bookstore/internal/infrastructure/database/supabase"
	"github.com/google/uuid"
)

type CreateBook struct {
	repo     book.BookRepository
	supabase *supabase.SupabaseClient
}

func NewCreateBookUseCase(repo book.BookRepository, supabase *supabase.SupabaseClient) *CreateBook {
	return &CreateBook{repo: repo, supabase: supabase}
}

func (uc *CreateBook) Execute(ctx context.Context, b *book.Book) (*book.Book, error) {
	// Ensure we have an ID
	if b.ID == "" {
		b.ID = UUIDGenerator()
	}

	// Local storage fallback: Supabase DNS (aeavumvbwryxbcfksepd.supabase.co) is failing.
	// We keep the files in the 'uploads' folder and return web-relative paths.

	if b.CoverUrl != "" && !isValidURL(b.CoverUrl) {
		// Convert "uploads/xxx.jpg" to "/uploads/xxx.jpg"
		b.CoverUrl = "/" + b.CoverUrl
	}

	if b.BookURL != "" && !isValidURL(b.BookURL) {
		// Convert "uploads/xxx.pdf" to "/uploads/xxx.pdf"
		b.BookURL = "/" + b.BookURL
	}

	// Persist book to database
	createdBook, err := uc.repo.CreateBook(b)
	if err != nil {
		return nil, err
	}
	return createdBook, nil
}

func isValidURL(url string) bool {
	return len(url) > 4 && url[:4] == "http"
}

func UUIDGenerator() string {
	id := uuid.New().String()
	return id
}
