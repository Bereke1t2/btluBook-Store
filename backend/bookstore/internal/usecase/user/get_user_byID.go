package user

import "github.com/bereke1t2/bookstore/internal/domain/user"


type GetUserByIDUseCase struct {
	userRepo user.UserRepository
}

func NewGetUserByIDUseCase(userRepo user.UserRepository) *GetUserByIDUseCase {
	return &GetUserByIDUseCase{
		userRepo: userRepo,
	}
}

func (uc *GetUserByIDUseCase) Execute(id string) (user.User, error) {
	foundUser, err := uc.userRepo.GetUserByID(id)
	if err != nil {
		return user.User{}, err
	}
	return foundUser, nil
}