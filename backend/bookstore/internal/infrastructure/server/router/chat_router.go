package router

import (
	"github.com/bereke1t2/bookstore/internal/infrastructure/server/handlers"
	"github.com/gin-gonic/gin"
)
func RegisterChatRoutes(r *gin.Engine, chatHandler *handlers.ChatHandler) {
	r.POST("/chats/multiple-choice/:id", chatHandler.GetMultipleChoiceQuestion)
	r.GET("/chats/responses/:id", chatHandler.GetChatResponses)
	r.POST("/chats/short-answer/:id", chatHandler.GetShortAnswerQuestion)
	r.POST("/chats/true-false/:id", chatHandler.GetTrueFalseQuestion)
}