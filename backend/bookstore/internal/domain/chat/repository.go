package chat


type ChatRepository interface {
	GetMultipleChoiceQuestion(id string , bookName string) ([]*MultipleQuiz, error)
	GetTrueFalseQuestion(id string , bookName string) ([]*TrueFalse, error)
	GetShortAnswerQuestion(id string , bookName string) ([]*ShortAnswer, error)
	GetChatResponses(chatID int , prompt string) (*ChatResponse, error)
}