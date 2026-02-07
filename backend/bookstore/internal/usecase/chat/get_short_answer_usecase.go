package usecase

import (
	"fmt"

	"github.com/bereke1t2/bookstore/internal/domain/chat"
)

type GetShortAnswerUseCase struct {
	chatRepo chat.ChatRepository
}

func NewGetShortAnswerUseCase(chatRepo chat.ChatRepository) *GetShortAnswerUseCase {
	return &GetShortAnswerUseCase{
		chatRepo: chatRepo,
	}
}

func (uc *GetShortAnswerUseCase) Execute(id string, bookName string) ([]*chat.ShortAnswer, error) {
	// Refined prompt for better JSON adherence and mandatory field population
	prompt := fmt.Sprintf(`
Act as an expert literary professor. Generate a comprehensive short-answer quiz for the book titled "%s".

Task:
Generate 10 challenging short-answer questions.
For EVERY question, you MUST provide the correct answer and a detailed explanation.

Rules:
1. ABSOLUTELY NO EMPTY FIELDS. Every "answer" and "explanation" field must be filled with high-quality content.
2. Focus on themes, character motivations, and key concepts.
3. Difficulty: Medium.
4. Do not include markdown formatting (like `+"```json"+`) in the response, return raw text only.

Strict JSON Structure:
{
  "book_title": "%s",
  "difficulty": "Medium",
  "quizzes": [
    {
      "id": 1,
      "question": "The actual question text?",
      "answer": "The concise correct answer.",
      "explanation": "A 1-2 sentence explanation of why this is correct based on the book."
    }
  ]
}
`, bookName, bookName)

	return uc.chatRepo.GetShortAnswerQuestion(id, prompt)
}
