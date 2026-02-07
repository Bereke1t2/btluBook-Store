package note

import (
	"context"
	"fmt"
	"strings"

	"github.com/bereke1t2/bookstore/internal/domain/note"
	"github.com/google/generative-ai-go/genai"
)

// AINoteSummarizer defines the interface for AI text processing.
type AINoteSummarizer interface {
	Summarize(ctx context.Context, text string) (string, error)
}

// GeminiSummarizer wraps a genai.GenerativeModel to summarize text.
type GeminiSummarizer struct {
	model *genai.GenerativeModel
}

func NewGeminiSummarizer(model *genai.GenerativeModel) *GeminiSummarizer {
	return &GeminiSummarizer{model: model}
}

func (s *GeminiSummarizer) Summarize(ctx context.Context, text string) (string, error) {
	s.model.SetMaxOutputTokens(1024)
	s.model.SetTemperature(0.3)
	s.model.ResponseMIMEType = "text/plain"

	prompt := fmt.Sprintf(`You are a helpful reading assistant. The user selected the following text from a book:
"%s"

Please provide a concise explanation and insight based on this text. 
CRITICAL INSTRUCTIONS:
- Provide ONLY the explanation. 
- DO NOT use any Markdown formatting (no **, #, or lists).
- DO NOT start with labels like "Summary:" or "Explanation:".
- Use plain text only.
- Max 150 words.`, text)

	resp, err := s.model.GenerateContent(ctx, genai.Text(prompt))
	if err != nil {
		if strings.Contains(err.Error(), "429") {
			return "", fmt.Errorf("AI rate limit reached. Please wait a moment and try again")
		}
		return "", err
	}

	if resp == nil || len(resp.Candidates) == 0 || resp.Candidates[0] == nil || resp.Candidates[0].Content == nil {
		return "", fmt.Errorf("no response from AI model")
	}

	var result strings.Builder
	for _, part := range resp.Candidates[0].Content.Parts {
		if t, ok := part.(genai.Text); ok {
			result.WriteString(string(t))
		}
	}
	return result.String(), nil
}

// GenerateAINoteUseCase generates an AI note from selected text.
type GenerateAINoteUseCase struct {
	repo       note.NoteRepository
	summarizer AINoteSummarizer
}

func NewGenerateAINoteUseCase(repo note.NoteRepository, summarizer AINoteSummarizer) *GenerateAINoteUseCase {
	return &GenerateAINoteUseCase{repo: repo, summarizer: summarizer}
}

func (uc *GenerateAINoteUseCase) Execute(ctx context.Context, userID int, bookID string, selectedText string) (*note.Note, error) {
	// Generate AI summary
	summary, err := uc.summarizer.Summarize(ctx, selectedText)
	if err != nil {
		return nil, err
	}

	// Create note with AI-generated content
	n := &note.Note{
		UserID:        userID,
		BookID:        bookID,
		Content:       summary,
		IsAIGenerated: true,
	}

	return uc.repo.Create(n)
}
