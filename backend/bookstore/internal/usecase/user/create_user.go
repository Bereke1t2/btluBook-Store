package user

import "github.com/bereke1t2/bookstore/internal/domain/user"


type CreateUserUseCase struct {
	userRepo user.UserRepository
}

func NewCreateUserUseCase(userRepo user.UserRepository) *CreateUserUseCase {
	return &CreateUserUseCase{
		userRepo: userRepo,
	}
}
func (uc *CreateUserUseCase) Execute(newUser user.User) (user.User, error) {
	us , err := uc.userRepo.GetUserByEmail(newUser.Email)
	if err == nil && us.ID != 0 {
		return user.User{},  nil
	}
	createdUser, err := uc.userRepo.CreateUser(newUser)
	if err != nil {
		return user.User{}, err
	}
	return createdUser, nil
}