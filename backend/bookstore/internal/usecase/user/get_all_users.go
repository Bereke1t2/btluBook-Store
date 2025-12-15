package user

import "github.com/bereke1t2/bookstore/internal/domain/user"

type GetAllUsers struct{
	repo user.UserRepository
}

func NewGetAllUsersUseCase(repo user.UserRepository) *GetAllUsers {
	return &GetAllUsers{
		repo: repo,
	}
}


func (uc *GetAllUsers) Execute() ([]user.User, error) {
	users, err := uc.repo.GetAllUsers()
	if err != nil {
		return nil, err
	}
	return users, nil
}