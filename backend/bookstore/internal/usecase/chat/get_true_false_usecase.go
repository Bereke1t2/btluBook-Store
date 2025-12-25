package chat

import (
	"fmt"

	"github.com/bereke1t2/bookstore/internal/domain/chat"
)

type GetTrueFalseQuestionUseCase struct {
	chatRepo chat.ChatRepository
}

func NewGetTrueFalseQuestionUseCase(chatRepo chat.ChatRepository) *GetTrueFalseQuestionUseCase {
	return &GetTrueFalseQuestionUseCase{
		chatRepo: chatRepo,
	}
}

func (uc *GetTrueFalseQuestionUseCase) Execute(id string , bookName string) ([]*chat.TrueFalse, error) {
	prompt := fmt.Sprintf(`
You are an AI assistant generating true/false quizzes for a bookstore mobile app.

Book context:
- Title: %s
- Author: %s

Task:
Generate %d true/false quiz questions based on the book.
Questions should test understanding of key ideas, themes, or concepts.
Do NOT include spoilers unless they are general and non-plot-specific.

Rules:
- Use clear, student-friendly language
- Each question must have one correct answer (true/false)
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

	return uc.chatRepo.GetTrueFalseQuestion(id , prompt)
}
