package chat

import (
	"fmt"

	"github.com/bereke1t2/bookstore/internal/domain/chat"
)

type GetChatResponseUseCase struct {
	chatRepo chat.ChatRepository
}

func NewGetChatResponseUseCase(chatRepo chat.ChatRepository) *GetChatResponseUseCase {
	return &GetChatResponseUseCase{
		chatRepo: chatRepo,
	}
}

func (uc *GetChatResponseUseCase) Execute(chatID string, prompt string, bookName string) ([]*chat.ChatResponse, error) {
prompt = fmt.Sprintf(`
You are a knowledgeable, concise AI book assistant in a bookstore app.

Book context:
- Title: %s

User question:
"%s"

Response rules:
- Answer exactly what is asked
- Use clear, student-friendly language
- Do NOT include spoilers
- If the question requires spoilers, answer at a high level only
- If information is uncertain or unavailable, say so and stay general
- Keep the response under 120 words

Return only the answer.
`, bookName, prompt)

	return uc.chatRepo.GetChatResponses(chatID , prompt)
}
