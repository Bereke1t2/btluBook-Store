package book

type Book struct {
	ID         string  `json:"id"`
	Title      string  `json:"title"`
	Author     string  `json:"author"`
	Price      float32 `json:"price"`
	Rating     float32 `json:"rating"`
	Category   string  `json:"category"`
	IsFeatured bool    `json:"is_featured"`
	SharedBy   string  `json:"shared_by"`
	Tag        string  `json:"tag"`
	CoverUrl   string  `json:"cover_url"`
	BookURL    string  `json:"book_url"`
	IsExternal bool    `json:"is_external"`
}

func NewBook(id, title, author string, price float32, coverURL, bookURL string, rating float32, category string, isFeatured bool, sharedBy string, tag string) *Book {
	return &Book{
		ID:         id,
		Title:      title,
		Author:     author,
		Price:      price,
		CoverUrl:   coverURL,
		BookURL:    bookURL,
		Rating:     rating,
		Category:   category,
		IsFeatured: isFeatured,
		SharedBy:   sharedBy,
		Tag:        tag,
	}
}
