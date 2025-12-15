package user

import (
	"errors"
	// "go/token"

	"github.com/bereke1t2/bookstore/internal/domain/user"
	"github.com/bereke1t2/bookstore/internal/infrastructure/security"
)

type LoginUseCase struct {
	userRepo user.UserRepository
}

func NewLoginUseCase(userRepo user.UserRepository) *LoginUseCase {
	return &LoginUseCase{userRepo: userRepo}
}

func (uc *LoginUseCase) Execute(email, password string) (user.User, string, error) {
	u, err := uc.userRepo.GetUserByEmail(email)
	if err != nil {
		return user.User{}, "", err
	}
	if u.Password != password {
		return user.User{}, "", errors.New("invalid credentials")
	}
	token, err := security.GenerateJWT(u.ID)
	if err != nil {
		return user.User{}, "", err
	}
	return u, token, nil
}