package chat

import "errors"

var (
	ErrChatNotFound      = errors.New("chat not found")
	ErrInvalidChatID     = errors.New("invalid chat ID")
	ErrChatAlreadyExists = errors.New("chat already exists")
	ErrInvalidChatInput  = errors.New("invalid chat input")
	ErrChatInternal      = errors.New("internal server error")
)