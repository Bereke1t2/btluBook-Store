package handlers

import (
	"net/http"
	"strconv"
	"time"

	bookUser "github.com/bereke1t2/bookstore/internal/domain/user"
	"github.com/bereke1t2/bookstore/internal/infrastructure/security"
	usecase "github.com/bereke1t2/bookstore/internal/usecase/user"
	"github.com/gin-gonic/gin"
)

type UserHandler struct {
	createUserUseCase   *usecase.CreateUserUseCase
	updateUserUseCase   *usecase.UpdateUserUseCase
	deleteUserUseCase   *usecase.DeleteUserUseCase
	getAllUsersUseCase  *usecase.GetAllUsers
	getUsersByIDUseCase *usecase.GetUserByIDUseCase
	loginUseCase        *usecase.LoginUseCase
}

func NewUserHandler(
	createUserUC *usecase.CreateUserUseCase,
	updateUserUC *usecase.UpdateUserUseCase,
	deleteUserUC *usecase.DeleteUserUseCase,
	getAllUsersUC *usecase.GetAllUsers,
	getUserByIDUC *usecase.GetUserByIDUseCase,
	loginUC *usecase.LoginUseCase,
) *UserHandler {
	return &UserHandler{
		createUserUseCase:   createUserUC,
		updateUserUseCase:   updateUserUC,
		deleteUserUseCase:   deleteUserUC,
		getAllUsersUseCase:  getAllUsersUC,
		getUsersByIDUseCase: getUserByIDUC,
		loginUseCase:        loginUC,
	}
}

func (h *UserHandler) CreateUser(c *gin.Context) {
	// Bind only the allowed input fields
	var input struct {
		Username string `json:"username" form:"username" binding:"required"`
		Email    string `json:"email" form:"email" binding:"required,email"`
		Password string `json:"password" form:"password" binding:"required,min=6"`
	}
	println("Creating User...")
	println("Content-Type: " + c.GetHeader("Content-Type"))
	// Accept both JSON and form-encoded payloads
	if err := c.ShouldBind(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid request payload: " + err.Error()})
		return
	}
	print("Input received: " + input.Email)
	println("Input Username: " + input.Username)

	// Hash the password before persisting
	hashedPassword, err := security.HashPassword(input.Password)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to hash password"})
		return
	}
	print("Password hashed.")

	// Build the domain user, only setting known fields
	// Build the domain user, only setting known fields
	newUser := bookUser.User{
		Username:     input.Username,
		Email:        input.Email,
		PasswordHash: string(hashedPassword), // store the hash, not the plaintext
	}
	print("User struct prepared.")
	createdUser, err := h.createUserUseCase.Execute(newUser)
	if err != nil || createdUser.ID == 0 {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	println("Created Username: " + createdUser.Username)
	println("Created Email: " + createdUser.Email)

	c.JSON(http.StatusCreated, gin.H{
		"data": gin.H{
			"user": createdUser,
			"error": "the user is created successfully without any issue",
		},
	})
}

func (h *UserHandler) GetAllUsers(c *gin.Context) {
	users, err := h.getAllUsersUseCase.Execute()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": gin.H{
		"users": users,
		},
	})
}

func (h *UserHandler) DeleteUser(c *gin.Context) {
	// Adjusted to match Router: DELETE /users/:id
	id := c.Param("id")
	
	// Parse id as integer
	parsedID, err := strconv.Atoi(id)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid user id"})
		return
	}
	
	userToDelete := bookUser.User{ID: parsedID}

	_, err = h.deleteUserUseCase.Execute(userToDelete)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.Status(http.StatusNoContent)
}
func (h *UserHandler) UpdateUser(c *gin.Context) {
	print("UpdateUser called\n")
	// PUT /users/:id
	id := c.Param("id")

	parsedID, err := strconv.Atoi(id)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid user id"})
		return
	}

	// Accept partial updates, map only allowed fields
	var input struct {
		Username     *string `json:"username"`
		Email        *string `json:"email"`
		Password     *string `json:"passwordHash"`
		ProfileImage *string `json:"profile_image"`
		// numeric fields are optional; if provided, use them
		BooksReadCount *int `json:"books_read_count"`
		ReadingStreak  *int `json:"reading_streak"`
		Points         *int `json:"points"`
		// lastReadDate optional RFC3339
		LastReadDate *string `json:"last_read_date"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid request payload: " + err.Error()})
		return
	}

	// Load existing user
	prev, err := h.getUsersByIDUseCase.Execute(id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	if prev.ID == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}

	updated := bookUser.User{
		ID:             parsedID,
		Username:       prev.Username,
		Email:          prev.Email,
		PasswordHash:   prev.PasswordHash,
		ProfileImage:   prev.ProfileImage,
		CreatedAt:      prev.CreatedAt,
		UpdatedAt:      prev.UpdatedAt,
		BooksReadCount: prev.BooksReadCount,
		ReadingStreak:  prev.ReadingStreak,
		LastReadDate:   prev.LastReadDate,
		Points:         prev.Points,
	}

	// Apply changes if provided
	if input.Username != nil {
		updated.Username = *input.Username
	}
	if input.Email != nil {
		updated.Email = *input.Email
	}
	if input.Password != nil {
		hashedPassword, err := security.HashPassword(*input.Password)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to hash password"})
			return
		}
		updated.PasswordHash = string(hashedPassword)
	}
	if input.ProfileImage != nil {
		// normalize: empty string -> nil
		if *input.ProfileImage == "" {
			updated.ProfileImage = nil
		} else {
			updated.ProfileImage = input.ProfileImage
		}
	}
	if input.BooksReadCount != nil {
		updated.BooksReadCount = *input.BooksReadCount
	}
	if input.ReadingStreak != nil {
		updated.ReadingStreak = *input.ReadingStreak
	}
	if input.Points != nil {
		updated.Points = *input.Points
	}
	if input.LastReadDate != nil {
		if *input.LastReadDate == "" {
			updated.LastReadDate = nil
		} else {
			t, err := time.Parse(time.RFC3339, *input.LastReadDate)
			if err != nil {
				c.JSON(http.StatusBadRequest, gin.H{"error": "invalid lastReadDate format, must be RFC3339"})
				return
			}
			updated.LastReadDate = &t
		}
	}

	// Always update UpdatedAt to now
	updated.UpdatedAt = time.Now()
	if updated.CreatedAt.IsZero() {
		updated.CreatedAt = time.Now()
	}

	user, err := h.updateUserUseCase.Execute(updated)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": gin.H{
			"user": user,
		},
	})
}

func (h *UserHandler) GetUserByID(c *gin.Context) {
	id := c.Param("id")

	user, err := h.getUsersByIDUseCase.Execute(id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	if user.ID == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": gin.H{
			"user": user,
		},
	})
}

func (h *UserHandler) LoginUser(c *gin.Context) {
	var loginRequest struct {
		Email    string `json:"email"`
		Password string `json:"password"`
	}

	if err := c.ShouldBindJSON(&loginRequest); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid request payload: " + err.Error()})
		return
	}

	user, token, err := h.loginUseCase.Execute(loginRequest.Email, loginRequest.Password)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data": gin.H{
			"user":  user,
			"token": token,
		},
	})
}