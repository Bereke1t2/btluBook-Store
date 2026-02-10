package handlers

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"strconv"

	book "github.com/bereke1t2/bookstore/internal/domain/book"
	usecase "github.com/bereke1t2/bookstore/internal/usecase/book"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type BookHandler struct {
	createBookUseCase       usecase.CreateBook
	getAllBooksUseCase      usecase.GetAllBooks
	deleteBookUseCase       usecase.DeleteBook
	getBookByIDUseCase      usecase.GetBookByID
	updateBookUseCase       usecase.UpdateBook
	getTrendingBooksUseCase usecase.GetTrendingBooks
}

func NewBookHandler(
	createBookUC usecase.CreateBook,
	getAllBooksUC usecase.GetAllBooks,
	deleteBookUC usecase.DeleteBook,
	getBookByIDUC usecase.GetBookByID,
	updateBookUC usecase.UpdateBook,
	getTrendingBooksUC usecase.GetTrendingBooks,
) *BookHandler {
	return &BookHandler{
		createBookUseCase:       createBookUC,
		getAllBooksUseCase:      getAllBooksUC,
		deleteBookUseCase:       deleteBookUC,
		getBookByIDUseCase:      getBookByIDUC,
		updateBookUseCase:       updateBookUC,
		getTrendingBooksUseCase: getTrendingBooksUC,
	}
}

func (h *BookHandler) GetAllBooks(c *gin.Context) {
	// Gin handles Content-Type automatically when using c.JSON
	books, err := h.getAllBooksUseCase.Execute()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": gin.H{
			"books": books,
		},
	})
}

func (h *BookHandler) DeleteBook(c *gin.Context) {
	// Original code used Query param (?id=...) for delete
	id := c.Query("id")

	err := h.deleteBookUseCase.Execute(id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.Status(http.StatusNoContent)
}

func (h *BookHandler) UpdateBook(c *gin.Context) {
	// Original code used Query param (?id=...) for update
	id := c.Query("id")

	var updatedBook book.Book
	// ShouldBindJSON binds the request body to the struct
	if err := c.ShouldBindJSON(&updatedBook); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	result, err := h.updateBookUseCase.Execute(id, &updatedBook)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": gin.H{
			"book": result,
		},
	})
}

func (h *BookHandler) GetBookByID(c *gin.Context) {
	// Original code used Mux Vars, which translates to Path Params in Gin (/books/:id)
	id := c.Param("id")

	book, err := h.getBookByIDUseCase.Execute(id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	if book == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Book not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": gin.H{
			"book": book,
		},
	})
}

func (h *BookHandler) GetTrendingBooks(c *gin.Context) {
	books, err := h.getTrendingBooksUseCase.Execute()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": gin.H{
			"books": books,
		},
	})
}
func (h *BookHandler) CreateBook(c *gin.Context) {
	// 1. Get text fields from form
	title := c.PostForm("title")
	author := c.PostForm("author")
	category := c.PostForm("category")
	sharedBy := c.PostForm("shared_by")
	ratingStr := c.PostForm("rating")
	var tag string
	if c.PostForm("tag") != "" {
		tag = c.PostForm("tag")
	}
	isFeatured := c.PostForm("is_featured") == "true"

	// Parse rating to float32
	var rating float32
	if ratingStr != "" {
		rf, err := strconv.ParseFloat(ratingStr, 32)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "invalid rating"})
			return
		}
		rating = float32(rf)
	}
	var price float32
	priceStr := c.PostForm("price")
	if priceStr != "" {
		pf, err := strconv.ParseFloat(priceStr, 32)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "invalid price"})
			return
		}
		price = float32(pf)
	}

	// 2. Get cover image file
	coverFile, err := c.FormFile("cover_url")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "cover image is required"})
		return
	}

	// Save cover image to temp file with unique name
	coverExt := filepath.Ext(coverFile.Filename)
	coverName := fmt.Sprintf("%s%s", uuid.New().String(), coverExt)
	coverPath := filepath.Join("uploads", coverName)

	// Ensure uploads directory exists
	if _, err := os.Stat("uploads"); os.IsNotExist(err) {
		os.Mkdir("uploads", 0755)
	}

	if err := c.SaveUploadedFile(coverFile, coverPath); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to save cover image"})
		return
	}

	// 3. Get book file (PDF)
	bookFile, err := c.FormFile("book_url")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "book file is required"})
		return
	}

	bookExt := filepath.Ext(bookFile.Filename)
	bookName := fmt.Sprintf("%s%s", uuid.New().String(), bookExt)
	bookPath := filepath.Join("uploads", bookName)

	if err := c.SaveUploadedFile(bookFile, bookPath); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to save book file"})
		return
	}

	// 4. Create Book entity
	newBook := book.Book{
		Title:      title,
		Author:     author,
		Category:   category,
		SharedBy:   sharedBy,
		Price:      price,
		Rating:     rating,
		Tag:        tag,
		IsFeatured: isFeatured,
		CoverUrl:   coverPath,
		BookURL:    bookPath,
	}

	// 5. Call use case
	createdBook, err := h.createBookUseCase.Execute(c.Request.Context(), &newBook)
	if err != nil {
		log.Printf("❌ Failed to create book usecase: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"data": gin.H{
			"book": createdBook,
		},
	})
}
