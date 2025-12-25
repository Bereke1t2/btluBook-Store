package chat

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


func (uc *GetShortAnswerUseCase) Execute(id string , bookName string) ([]*chat.ShortAnswer, error) {
	prompt := fmt.Sprintf(`
You are an AI assistant generating short-answer quizzes for a bookstore mobile app.

Book context:
- Title: %s
- Author: %s

Task:
Generate %d short-answer quiz questions based on the book.
Questions should test understanding of key ideas, themes, or concepts.
Do NOT include spoilers unless they are general and non-plot-specific.

Rules:
- Use clear, student-friendly language
- Each question must have one concise answer
- Provide a short explanation for each answer
- Difficulty level: %s
- If exact details are uncertain, stay general and conceptual

Output format:
Return ONLY valid JSON in the following exact structure.
Do NOT include markdown, comments, or extra text.

{
  "book_title": "%s",
  "difficulty": "%s",
  "quizzes": [
    {
      "id": 1,
      "question": "string",
      "answer": "string",
      "explanation": "string"
    }
  ]
}
`, bookName, bookName, 10, "Medium", bookName, "Medium")

	return uc.chatRepo.GetShortAnswerQuestion(id , prompt)
}