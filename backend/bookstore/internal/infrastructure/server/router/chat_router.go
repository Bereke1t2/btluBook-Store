package router

import (
	"github.com/bereke1t2/bookstore/internal/infrastructure/middleware"
	"github.com/bereke1t2/bookstore/internal/infrastructure/server/handlers"
	"github.com/gin-gonic/gin"
)

func RegisterChatRoutes(r *gin.Engine, chatHandler *handlers.ChatHandler) {
	chat := r.Group("/chats")

	chat.Use(middleware.AuthMiddleware)

	chat.POST("/questions/multiple-choice/:id", chatHandler.GetMultipleChoiceQuestion)
	chat.POST("/responses/:id", chatHandler.GetChatResponses)
	chat.POST("/questions/short-answer/:id", chatHandler.GetShortAnswerQuestion)
	chat.POST("/questions/true-false/:id", chatHandler.GetTrueFalseQuestion)
	r.GET("/stream", chatHandler.StreamChatResponses)
}
