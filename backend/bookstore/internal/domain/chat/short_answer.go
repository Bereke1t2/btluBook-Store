package chat

type ShortAnswer struct {
	ID            string `json:"id"`
	Question      string `json:"question"`
	CorrectAnswer string `json:"correct_answer"`
}