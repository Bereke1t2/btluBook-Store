package chat

type MultipleQuiz struct {
	ID            int   `json:"id"`
	Question      string   `json:"question"`
	Options       []string `json:"options"`
	CorrectIndex int   `json:"correct_index"`
	Explanation  string `json:"explanation"`
}
