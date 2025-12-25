package chat

import (
	"fmt"

	"github.com/bereke1t2/bookstore/internal/domain/chat"
)

type GetMultipleChoiceQuestionUseCase struct {
	chatRepo chat.ChatRepository
}

func NewGetMultipleChoiceQuestionUseCase(chatRepo chat.ChatRepository) *GetMultipleChoiceQuestionUseCase {
	return &GetMultipleChoiceQuestionUseCase{
		chatRepo: chatRepo,
	}
}

func (uc *GetMultipleChoiceQuestionUseCase) Execute(id string, bookName string) ([]*chat.MultipleQuiz, error) {
	// REQUEST 10 QUESTIONS (20 often causes the JSON to break due to size)
	numQuestions := 10
	difficulty := "medium"

	prompt := fmt.Sprintf(`
Generate %d multiple-choice questions for the book "%s".

Requirements:
- JSON output only.
- 4 options per question.
- 1 correct answer.
- Keep explanations very concise (1 sentence).

Format:
{
  "book_title": "%s",
  "difficulty": "%s",
  "quizzes": [
    {
      "id": 1,
      "question": "string",
      "options": ["string", "string", "string", "string"],
      "correct_answer_index": 0,
      "explanation": "string"
    }
  ]
}
`, numQuestions, bookName, bookName, difficulty)

	return uc.chatRepo.GetMultipleChoiceQuestion(id, prompt)
}