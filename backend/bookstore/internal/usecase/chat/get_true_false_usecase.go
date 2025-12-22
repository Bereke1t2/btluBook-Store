package chat


import (
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

func (uc *GetTrueFalseQuestionUseCase) Execute(id string , bookName string) (*chat.TrueFalse, error) {
	return uc.chatRepo.GetTrueFalseQuestion(id , bookName)
}
