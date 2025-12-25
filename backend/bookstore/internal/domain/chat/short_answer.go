package chat

type ShortAnswer struct {
	ID            int `json:"id"`
	Question      string `json:"question"`
	CorrectAnswer string `json:"correct_answer"`
}