package externalapis

import (
	"context"

	"github.com/bereke1t2/bookstore/internal/domain/chat"
	"github.com/google/generative-ai-go/genai"
	"google.golang.org/api/option"
)


type GeminiClient struct {
	ctx  context.Context
	model *genai.GenerativeModel
}
func NewGeminiClient(apiKey string, ctx context.Context) (*GeminiClient, error) {
	client, err := genai.NewClient(ctx, option.WithAPIKey(apiKey))
	if err != nil {
		return nil, err
	}
	model := client.GenerativeModel("gemini-1.5-flash")
	return &GeminiClient{
		ctx:  ctx,
		model: model,
	}, nil
}


type ChatResponseImpl struct {
	geminiClient *GeminiClient
}

var _ chat.ChatRepository = (*ChatResponseImpl)(nil)

func NewChatResponseImpl(geminiClient *GeminiClient) *ChatResponseImpl {
	return &ChatResponseImpl{
		geminiClient: geminiClient,
	}
}

func (gc *ChatResponseImpl) GetChatResponses(chatID string, prompt string) (*chat.ChatResponse, error) {
	resp, err := gc.geminiClient.model.GenerateContent(gc.geminiClient.ctx, genai.Text(prompt))
	if err != nil {
		return nil, err
	}
	if len(resp.Candidates) == 0 || resp.Candidates[0].Content == nil {
		return &chat.ChatResponse{
			ID:      chatID,
			ChatID:  chatID,
			Message: "",
		}, nil
	}
	var out string
	for _, part := range resp.Candidates[0].Content.Parts {
		if t, ok := part.(genai.Text); ok {
			out += string(t)
		}
	}
	chatResponse := &chat.ChatResponse{
		ID:      chatID,
		ChatID:  chatID,
		Message: out,
	}
	return chatResponse, nil
}

func (gc *ChatResponseImpl) GetMultipleChoiceQuestion(chatID string, prompt string) (*chat.ChatResponse, error) {
	return gc.GetChatResponses(chatID, prompt)
}

func (gc *ChatResponseImpl) GetTrueFalseQuestion(chatID string, prompt string) (*chat.ChatResponse, error) {
	return gc.GetChatResponses(chatID, prompt)
}
func (gc *ChatResponseImpl) GetShortAnswerQuestion(chatID string, prompt string) (*chat.ChatResponse, error) {
	return gc.GetChatResponses(chatID, prompt)
}
