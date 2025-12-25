package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"time"

	Gemini "github.com/bereke1t2/bookstore/internal/infrastructure/externalapis"
	postgres "github.com/bereke1t2/bookstore/internal/infrastructure/database/postgres"
	"github.com/bereke1t2/bookstore/internal/infrastructure/database/supabase"
	handler "github.com/bereke1t2/bookstore/internal/infrastructure/server/handlers"
	router "github.com/bereke1t2/bookstore/internal/infrastructure/server/router"
	bookusecase "github.com/bereke1t2/bookstore/internal/usecase/book"
	userusecase "github.com/bereke1t2/bookstore/internal/usecase/user"
	chatusecase "github.com/bereke1t2/bookstore/internal/usecase/chat"
	"github.com/gin-gonic/gin"

	// "github.com/gorilla/mux"

	"github.com/joho/godotenv"
	// "github.com/google/generative-ai-go/genai"
)

func main() {

	r := gin.Default()
	db := postgres.NewPostgresDBConnection()
	defer db.Close()

	err := godotenv.Load()
	if err != nil {
		log.Fatal("❌ Error loading .env file:", err)
	}
	supabaseClient := supabase.NewSupabaseClient(os.Getenv("SUPABASE_URL"), os.Getenv("SUPABASE_SERVICE_KEY"))
	geminiApiKey := os.Getenv("GEMINI_API_KEY")
	_ = geminiApiKey
	geminiClient, err := Gemini.NewGeminiClient(geminiApiKey,context.Background())
	if err != nil {
		log.Fatal("❌ Error creating Gemini client:", err)
	}


	chatRepo := Gemini.NewChatResponseImpl(geminiClient)
	bookRepo := postgres.NewBookRepositoryImpl(db)
	userRepo := postgres.NewUserRepositoryPostgres(db)

	createBookUC := bookusecase.NewCreateBookUseCase(bookRepo, supabaseClient)
	getBookByIDUC := bookusecase.NewGetBookByIDUseCase(bookRepo)
	updateBookUC := bookusecase.NewUpdateBookUseCase(bookRepo)
	deleteBookUC := bookusecase.NewDeleteBookUsecase(bookRepo)
	getAllBooksUC := bookusecase.NewGetAllBooksUseCase(bookRepo)


	getChatResponsesUC := chatusecase.NewGetChatResponseUseCase(chatRepo)
	getMultipleChoiceUC := chatusecase.NewGetMultipleChoiceQuestionUseCase(chatRepo)
	getTrueFalseUC := chatusecase.NewGetTrueFalseQuestionUseCase(chatRepo)
	getShortAnswerUC := chatusecase.NewGetShortAnswerUseCase(chatRepo)


	createUserUC := userusecase.NewCreateUserUseCase(userRepo)
	getUserByIDUC := userusecase.NewGetUserByIDUseCase(userRepo)
	updateUserUC := userusecase.NewUpdateUserUseCase(userRepo)
	deleteUserUC := userusecase.NewDeleteUserUsecase(userRepo)
	getAllUsersUC := userusecase.NewGetAllUsersUseCase(userRepo)
	// getUserByEmailUc := userusecase.NewGetUserByEmailUseCase(userRepo)
	loginUC := userusecase.NewLoginUseCase(userRepo)

	userHandler := handler.NewUserHandler(createUserUC, updateUserUC , deleteUserUC , getAllUsersUC,getUserByIDUC, loginUC)
	bookHandler := handler.NewBookHandler(*createBookUC, *getAllBooksUC, *deleteBookUC, *getBookByIDUC, *updateBookUC)
	chatHandler := handler.NewChatHandler(*getMultipleChoiceUC, *getTrueFalseUC, *getShortAnswerUC, *getChatResponsesUC)

	router.SetupRoutes(r, bookHandler , userHandler, chatHandler)

	srv := &http.Server{
		Handler:      r,
		Addr:         "0.0.0.0:8080",
		WriteTimeout: 120 * time.Second,
		ReadTimeout:  120 * time.Second,
	}

	log.Println("Starting server on :8080")
	if err := srv.ListenAndServe(); err != nil {
		log.Fatalf("Server failed to start: %v", err)
	}
}