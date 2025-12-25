package externalapis

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"strings"

	"github.com/bereke1t2/bookstore/internal/domain/chat"
	"github.com/google/generative-ai-go/genai"
	"google.golang.org/api/option"
)

type GeminiClient struct {
	ctx   context.Context
	model *genai.GenerativeModel
}

func NewGeminiClient(apiKey string, ctx context.Context) (*GeminiClient, error) {
	client, err := genai.NewClient(ctx, option.WithAPIKey(apiKey))
	if err != nil {
		return nil, err
	}

	// CHANGED: Use "gemini-2.5-flash-lite" - This is the best free model in late 2025
	model := client.GenerativeModel("gemini-2.5-flash-lite")

	return &GeminiClient{
		ctx:   ctx,
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

func extractText(resp *genai.GenerateContentResponse) string {
	if resp == nil || len(resp.Candidates) == 0 || resp.Candidates[0] == nil || resp.Candidates[0].Content == nil {
		return ""
	}
	var message strings.Builder
	for _, part := range resp.Candidates[0].Content.Parts {
		if t, ok := part.(genai.Text); ok {
			message.WriteString(string(t))
		}
	}
	return message.String()
}

func parseQuizzes[T any](raw string) ([]T, error) {
	type responseDTO struct {
		BookTitle  string `json:"book_title"`
		Difficulty string `json:"difficulty"`
		Quizzes    []T    `json:"quizzes"`
	}

	raw = strings.TrimSpace(raw)
	raw = strings.TrimPrefix(raw, "```json")
	raw = strings.TrimPrefix(raw, "```")
	raw = strings.TrimSuffix(raw, "```")
	raw = strings.TrimSpace(raw)

	var data responseDTO
	if err := json.Unmarshal([]byte(raw), &data); err != nil {
		return nil, fmt.Errorf("failed to parse JSON from model: %w", err)
	}

	return data.Quizzes, nil
}

func (r *ChatResponseImpl) GetMultipleChoiceQuestion(id string, prompt string) ([]*chat.MultipleQuiz, error) {
	// For the Free Lite model, keep tokens lower to avoid hitting the "Tokens Per Minute" limit
	r.geminiClient.model.SetMaxOutputTokens(4000) 
	r.geminiClient.model.SetTemperature(0.2)
	r.geminiClient.model.ResponseMIMEType = "application/json"

	resp, err := r.geminiClient.model.GenerateContent(r.geminiClient.ctx, genai.Text(prompt))
	if err != nil {
		// Detect if we are hitting the free tier rate limit
		if strings.Contains(err.Error(), "429") {
			return nil, errors.New("free tier limit reached. Please wait 1 minute before trying again")
		}
		return nil, err
	}

	raw := extractText(resp)
	print(raw)
	quizzes, err := parseQuizzes[chat.MultipleQuiz](raw)
	if err != nil {
		return nil, err
	}

	result := make([]*chat.MultipleQuiz, len(quizzes))
	for i := range quizzes {
		result[i] = &quizzes[i]
	}
	return result, nil
}

// Implement True/False and Short Answer similarly...
func (r *ChatResponseImpl) GetTrueFalseQuestion(id string, prompt string) ([]*chat.TrueFalse, error) {
	r.geminiClient.model.SetMaxOutputTokens(2000)
	r.geminiClient.model.ResponseMIMEType = "application/json"
	resp, err := r.geminiClient.model.GenerateContent(r.geminiClient.ctx, genai.Text(prompt))
	if err != nil { return nil, err }
	quizzes, err := parseQuizzes[chat.TrueFalse](extractText(resp))
	if err != nil { return nil, err }
	result := make([]*chat.TrueFalse, len(quizzes))
	for i := range quizzes { result[i] = &quizzes[i] }
	return result, nil
}

func (r *ChatResponseImpl) GetShortAnswerQuestion(id string, prompt string) ([]*chat.ShortAnswer, error) {
	r.geminiClient.model.SetMaxOutputTokens(2000)
	r.geminiClient.model.ResponseMIMEType = "application/json"
	resp, err := r.geminiClient.model.GenerateContent(r.geminiClient.ctx, genai.Text(prompt))
	if err != nil { return nil, err }
	quizzes, err := parseQuizzes[chat.ShortAnswer](extractText(resp))
	if err != nil { return nil, err }
	result := make([]*chat.ShortAnswer, len(quizzes))
	for i := range quizzes { result[i] = &quizzes[i] }
	return result, nil
}

func (r *ChatResponseImpl) GetChatResponses(chatID int, prompt string) (*chat.ChatResponse, error) {
	r.geminiClient.model.SetMaxOutputTokens(1000)
	r.geminiClient.model.ResponseMIMEType = "text/plain"
	resp, err := r.geminiClient.model.GenerateContent(r.geminiClient.ctx, genai.Text(prompt))
	if err != nil { return nil, err }
	return &chat.ChatResponse{ID: chatID, ChatID: chatID, Message: extractText(resp)}, nil
}