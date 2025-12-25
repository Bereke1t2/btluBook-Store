package chat

type TrueFalse struct {
	ID       int `json:"id"`
	Question string `json:"question"`
	Answer   bool   `json:"answer"`
}