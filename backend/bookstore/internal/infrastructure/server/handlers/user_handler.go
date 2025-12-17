package handlers

import (
	"net/http"
	"strconv"

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
	
	// Create a temporary user struct with the ID to pass to the usecase
	// (Assuming your usecase expects a User struct to extract the ID)
	
	userToDelete := bookUser.User{ID: parsedID}

	_, err = h.deleteUserUseCase.Execute(userToDelete)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.Status(http.StatusNoContent)
}
func (h *UserHandler) UpdateUser(c *gin.Context) {
	// Adjusted to match Router: PUT /users/:id
	id := c.Param("id")

	// Parse id as integer
	parsedID, err := strconv.Atoi(id)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid user id"})
		return
	}

	var updatedUser bookUser.User
	if err := c.ShouldBindJSON(&updatedUser); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Ensure the ID from the URL overrides any ID sent in the body (security best practice)
	updatedUser.ID = parsedID

	user, err := h.updateUserUseCase.Execute(updatedUser)
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
	// Original code used Query param, but Router defined /users/:id
	// So we must use c.Param
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
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	user, token ,  err := h.loginUseCase.Execute(loginRequest.Email, loginRequest.Password)
	if err != nil {
		// Use StatusUnauthorized (401) for login failures
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