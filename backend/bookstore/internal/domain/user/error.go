package user

import (
	"errors"
)

var (
	ErrNotFound        = errors.New("user not found")
	ErrAlreadyExists   = errors.New("user already exists")
	ErrInvalidInput    = errors.New("invalid user input")
	ErrInternal        = errors.New("internal server error")
)
