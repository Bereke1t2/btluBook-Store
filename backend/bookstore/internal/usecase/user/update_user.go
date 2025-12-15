package user

import "github.com/bereke1t2/bookstore/internal/domain/user"


type UpdateUserUseCase struct {
	userRepo user.UserRepository
}

func NewUpdateUserUseCase(userRepo user.UserRepository) *UpdateUserUseCase {
	return &UpdateUserUseCase{
		userRepo: userRepo,
	}
}
func (uc *UpdateUserUseCase) Execute(updatedUser user.User) (user.User, error) {
	updated, err := uc.userRepo.UpdateUser(updatedUser)
	if err != nil {
		return user.User{}, err
	}
	return updated, nil
}