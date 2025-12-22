package chat


import (
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


func (uc *GetShortAnswerUseCase) Execute(id string , bookName string) (*chat.ShortAnswer, error) {
	return uc.chatRepo.GetShortAnswerQuestion(id , bookName)
}