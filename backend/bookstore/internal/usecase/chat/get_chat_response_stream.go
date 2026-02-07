package usecase

import (
	"context"

	"github.com/bereke1t2/bookstore/internal/domain/chat"
)

type GetChatResponseStreamUseCase struct {
	Repo chat.ChatRepository
}

func NewGetChatResponseStreamUseCase(repo chat.ChatRepository) *GetChatResponseStreamUseCase {
	return &GetChatResponseStreamUseCase{Repo: repo}
}

func (uc *GetChatResponseStreamUseCase) Execute(ctx context.Context, prompt string) (<-chan string, error) {
	return uc.Repo.GetChatResponseStream(ctx, prompt)
}
