package user

import "github.com/bereke1t2/bookstore/internal/domain/user"



type GetUserByEmailUseCase struct {
	userRepo user.UserRepository
}

func NewGetUserByEmailUseCase(userRepo user.UserRepository) *GetUserByEmailUseCase {
	return &GetUserByEmailUseCase{
		userRepo: userRepo,
	}
}
func (uc *GetUserByEmailUseCase) Execute(email string) (user.User, error) {
	foundUser, err := uc.userRepo.GetUserByEmail(email)
	if err != nil {
		return user.User{}, err
	}
	return foundUser, nil
}