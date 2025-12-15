package user

type UserRepository interface{
	CreateUser(user User) (User, error)
	GetUserByID(id string) (User, error)
	UpdateUser(user User) (User, error)
	DeleteUser(id string) error
	GetAllUsers() ([]User, error)
	GetUserByEmail(email string) (User, error)
}