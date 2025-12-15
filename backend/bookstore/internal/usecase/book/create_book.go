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
	// Ensure we have an ID before using it in storage paths
	b.ID = UUIDGenerator()

	// Upload book image to Supabase
	if b.CoverUrl != "" {
		imageURL, err := uc.supabase.UploadToSupabase(b.CoverUrl, "images/"+b.ID, "images")
		if err != nil {
			return nil, err
		}
		b.CoverUrl = imageURL
	}

	// Upload book file to Supabase
	if b.BookURL != "" {
		bookURL, err := uc.supabase.UploadToSupabase(b.BookURL, "files/"+b.ID, "books")
		if err != nil {
			return nil, err
		}
		b.BookURL = bookURL
	}

	// Persist book
	createdBook, err := uc.repo.CreateBook(b)
	if err != nil {
		return nil, err
	}
	return createdBook, nil
}

func UUIDGenerator() string {
	id := uuid.New().String()
	return id
}