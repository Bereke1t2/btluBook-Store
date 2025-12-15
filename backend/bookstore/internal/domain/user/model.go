package user


type User struct {
	ID       string `json:"id"`
	Username string `json:"username"`
	Email    string `json:"email"`
	Password string `json:"password"`
}

func NewUser(id, username, email, password string) *User {
	return &User{
		ID:       id,
		Username: username,
		Email:    email,
		Password: password,
	}
}