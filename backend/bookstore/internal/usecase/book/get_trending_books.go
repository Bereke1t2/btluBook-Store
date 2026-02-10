package book

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strings"

	"github.com/bereke1t2/bookstore/internal/domain/book"
)

type GetTrendingBooks struct{}

func NewGetTrendingBooks() *GetTrendingBooks {
	return &GetTrendingBooks{}
}

// Google Books API Response Structures
type googleBooksResponse struct {
	Items []struct {
		ID         string `json:"id"`
		VolumeInfo struct {
			Title         string   `json:"title"`
			Authors       []string `json:"authors"`
			Description   string   `json:"description"`
			AverageRating float32  `json:"averageRating"`
			ImageLinks    struct {
				Thumbnail string `json:"thumbnail"`
			} `json:"imageLinks"`
			PreviewLink string `json:"previewLink"`
		} `json:"volumeInfo"`
		SaleInfo struct {
			ListPrice struct {
				Amount float32 `json:"amount"`
			} `json:"listPrice"`
		} `json:"saleInfo"`
	} `json:"items"`
}

func (uc *GetTrendingBooks) Execute() ([]book.Book, error) {
	// Query for new fiction books
	url := "https://www.googleapis.com/books/v1/volumes?q=subject:fiction&orderBy=newest&maxResults=10&langRestrict=en"

	resp, err := http.Get(url)
	if err != nil {
		return nil, fmt.Errorf("failed to fetch from Google Books: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("google Books API returned status: %d", resp.StatusCode)
	}

	var gResp googleBooksResponse
	if err := json.NewDecoder(resp.Body).Decode(&gResp); err != nil {
		return nil, fmt.Errorf("failed to decode response: %w", err)
	}

	var books []book.Book
	for _, item := range gResp.Items {
		author := "Unknown Author"
		if len(item.VolumeInfo.Authors) > 0 {
			author = strings.Join(item.VolumeInfo.Authors, ", ")
		}

		price := item.SaleInfo.ListPrice.Amount
		if price == 0 {
			// Mock price if not available, just for display
			price = 9.99
		}

		// Ensure thumbnail uses HTTPS
		coverUrl := item.VolumeInfo.ImageLinks.Thumbnail
		if strings.HasPrefix(coverUrl, "http://") {
			coverUrl = strings.Replace(coverUrl, "http://", "https://", 1)
		}

		b := book.Book{
			ID:         item.ID,
			Title:      item.VolumeInfo.Title,
			Author:     author,
			Category:   "Trending",
			Price:      price,
			Rating:     item.VolumeInfo.AverageRating,
			CoverUrl:   coverUrl,
			BookURL:    item.VolumeInfo.PreviewLink, // Use preview link as book URL
			IsFeatured: false,
			IsExternal: true,
		}
		books = append(books, b)
	}

	return books, nil
}
