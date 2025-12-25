package chat
type ChatResponse struct {
	ID      int `json:"id"`
	ChatID  int `json:"chat_id"`
	Message string `json:"message"`
}