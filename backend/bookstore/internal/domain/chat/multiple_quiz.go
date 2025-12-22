package chat

type MultipleQuiz struct {
	ID            string   `json:"id"`
	Question      string   `json:"question"`
	Options       []Option `json:"options"`
	CorrectOption string   `json:"correct_option"`
}
type Option struct {
	ID       string `json:"id"`
	Text     string `json:"text"`
	IsAnswer bool   `json:"is_answer"`
}