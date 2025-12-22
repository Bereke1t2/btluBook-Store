package chat
type ChatResponse struct {
	ID      string `json:"id"`
	ChatID  string `json:"chat_id"`
	Message string `json:"message"`
}