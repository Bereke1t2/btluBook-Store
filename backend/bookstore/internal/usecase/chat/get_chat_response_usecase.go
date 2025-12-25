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
func (uc *GetChatResponseUseCase) Execute(chatID int, prompt string, bookName string) (*chat.ChatResponse, error) {
    // We wrap the user's prompt with system instructions
	formattedPrompt := fmt.Sprintf(`
You are the "Bookstore Concierge," a knowledgeable and friendly AI. 
Your goal is to answer questions about the book "%s" for a customer.

Constraints:
1. Answer: "%s"
2. Length: Maximum 120 words.
3. Spoilers: Do NOT reveal major plot twists or endings. If the question asks for one, explain that you want to keep the reading experience fresh for them.
4. Tone: Student-friendly, encouraging, and professional.
5. Content: If you are unsure about a specific detail, provide a general conceptual answer rather than guessing.

Return ONLY the text of your response. No headers, no JSON, no markdown.
`, bookName, prompt)

	return uc.chatRepo.GetChatResponses(chatID, formattedPrompt)
}