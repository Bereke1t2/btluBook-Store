package handlers

import (
	"net/http"
	// "strconv"

	usecase "github.com/bereke1t2/bookstore/internal/usecase/chat"
	"github.com/gin-gonic/gin"
)

type ChatHandler struct {
	GetMultipleQuuizUseCase usecase.GetMultipleChoiceQuestionUseCase
	GetTrueFalseUseCase     usecase.GetTrueFalseQuestionUseCase
	GetShortAnswerUseCase   usecase.GetShortAnswerUseCase
	GetChatResponsesUseCase usecase.GetChatResponseUseCase
}

func NewChatHandler(
	getMultipleQuuizUC usecase.GetMultipleChoiceQuestionUseCase,
	getTrueFalseUC usecase.GetTrueFalseQuestionUseCase,
	getShortAnswerUC usecase.GetShortAnswerUseCase,
	getChatResponsesUC usecase.GetChatResponseUseCase,
) *ChatHandler {
	return &ChatHandler{
		GetMultipleQuuizUseCase: getMultipleQuuizUC,
		GetTrueFalseUseCase:     getTrueFalseUC,
		GetShortAnswerUseCase:   getShortAnswerUC,
		GetChatResponsesUseCase: getChatResponsesUC,
	}
}

func (h *ChatHandler) GetChatResponses(c *gin.Context) {
	chatID := 1
	var body struct {
		Prompt   string `json:"prompt" binding:"required"`
		BookName string `json:"book_name" binding:"required"`
	}

	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": err.Error(),
		})
		return
	}
	if body.Prompt == "" || body.BookName == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing required parameters"})
		return
	}
	responses, err := h.GetChatResponsesUseCase.Execute(chatID, body.Prompt, body.BookName)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, responses)
}
func (h *ChatHandler) GetMultipleChoiceQuestion(c *gin.Context) {
	chatID := c.Param("id")
	var body struct {
		BookName string `json:"book_name" binding:"required"`
	}

	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": err.Error(),
		})
		return
	}
	bookName := body.BookName
	if chatID == "" || bookName == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing required parameters", "chatID": chatID, "bookName": bookName})
		return
	}
	question, err := h.GetMultipleQuuizUseCase.Execute(chatID, bookName)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, question)
}

func (h *ChatHandler) GetTrueFalseQuestion(c *gin.Context) {
	chatID := c.Param("id")
	var body struct {
		BookName string `json:"book_name" binding:"required"`
	}

	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": err.Error(),
		})
		return
	}
	bookName := body.BookName
	if chatID == "" || bookName == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing required parameters", "chatID": chatID, "bookName": bookName})
		return
	}
	question, err := h.GetTrueFalseUseCase.Execute(chatID, bookName)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, question)
}
func (h *ChatHandler) GetShortAnswerQuestion(c *gin.Context) {
	chatID := c.Param("id")
	var body struct {
		BookName string `json:"book_name" binding:"required"`
	}

	if err := c.ShouldBindJSON(&body); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": err.Error(),
		})
		return
	}
	bookName := body.BookName
	if chatID == "" || bookName == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing required parameters", "chatID": chatID, "bookName": bookName})
		return
	}
	question, err := h.GetShortAnswerUseCase.Execute(chatID, bookName)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, question)
}
