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
func (uc *GetTrueFalseQuestionUseCase) Execute(id string, bookName string) ([]*chat.TrueFalse, error) {
	prompt := fmt.Sprintf(`
Act as a literary quiz creator. Generate a True/False quiz for the book "%s".

Task:
Generate 10 True/False questions. 
For every question, you MUST provide the correct boolean answer ("true" or "false") and a short explanation.

Rules:
- DO NOT leave any "answer" or "explanation" fields blank.
- The "answer" must be a string: either "true" or "false".
- Focus on themes, motifs, and major concepts.
- Difficulty: Medium.
- Response must be raw JSON only (no markdown, no backticks).

JSON Structure:
{
  "book_title": "%s",
  "difficulty": "Medium",
  "quizzes": [
    {
      "id": 1,
      "question": "The main theme of this book is...",
      "answer": "true",
      "explanation": "This is correct because the author emphasizes..."
    }
  ]
}
`, bookName, bookName)

	return uc.chatRepo.GetTrueFalseQuestion(id, prompt)
}