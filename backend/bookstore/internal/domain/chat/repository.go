package chat


type ChatRepository interface {
	GetMultipleChoiceQuestion(id string , bookName string) (*ChatResponse, error)
	GetTrueFalseQuestion(id string , bookName string) (*ChatResponse, error)
	GetShortAnswerQuestion(id string , bookName string) (*ChatResponse, error)
	GetChatResponses(chatID string , prompt string) (*ChatResponse, error)
}