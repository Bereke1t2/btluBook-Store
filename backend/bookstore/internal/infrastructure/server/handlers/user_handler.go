package handlers

import (
	"net/http"

	bookUser "github.com/bereke1t2/bookstore/internal/domain/user"
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
	var newUser bookUser.User
	if err := c.ShouldBindJSON(&newUser); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	createdUser, err := h.createUserUseCase.Execute(newUser)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"data": gin.H{
			"user": createdUser,
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
	
	// Create a temporary user struct with the ID to pass to the usecase
	// (Assuming your usecase expects a User struct to extract the ID)
	userToDelete := bookUser.User{ID: id}

	_, err := h.deleteUserUseCase.Execute(userToDelete)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.Status(http.StatusNoContent)
}

func (h *UserHandler) UpdateUser(c *gin.Context) {
	// Adjusted to match Router: PUT /users/:id
	id := c.Param("id")

	var updatedUser bookUser.User
	if err := c.ShouldBindJSON(&updatedUser); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Ensure the ID from the URL overrides any ID sent in the body (security best practice)
	updatedUser.ID = id

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
	if user.ID == "" {
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