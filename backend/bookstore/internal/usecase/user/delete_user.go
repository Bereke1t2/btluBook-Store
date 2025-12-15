package user

import "github.com/bereke1t2/bookstore/internal/domain/user"


type DeleteUserUseCase struct {
	userRepo user.UserRepository
}

func NewDeleteUserUsecase(userRepo user.UserRepository) *DeleteUserUseCase {
	return &DeleteUserUseCase{
		userRepo: userRepo,
	}
}
func (uc *DeleteUserUseCase) Execute(updatedUser user.User) (user.User, error) {
	updated, err := uc.userRepo.UpdateUser(updatedUser)
	if err != nil {
		return user.User{}, err
	}
	return updated, nil
}