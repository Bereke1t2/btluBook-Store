package book

import (
	"errors"
)

var (
	ErrBookNotFound       = errors.New("book not found")
	ErrInvalidBookID      = errors.New("invalid book ID")
	ErrBookAlreadyExists  = errors.New("book already exists")
	ErrInvalidBookInput   = errors.New("invalid book input")
	ErrBookInternal       = errors.New("internal server error")
)