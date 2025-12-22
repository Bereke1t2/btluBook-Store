package chat

import (
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

func (uc *GetMultipleChoiceQuestionUseCase) Execute(id string , bookName string) (*chat.MultipleQuiz, error) {
	return uc.chatRepo.GetMultipleChoiceQuestion(id , bookName)
}