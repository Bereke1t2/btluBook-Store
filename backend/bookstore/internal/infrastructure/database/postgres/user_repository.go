package postgres

import (
	"database/sql"
	"github.com/bereke1t2/bookstore/internal/domain/user"
)

var _ user.UserRepository = (*UserRepositoryPostgres)(nil)


type UserRepositoryPostgres struct {
	db *sql.DB
}

func NewUserRepositoryPostgres(db *sql.DB) *UserRepositoryPostgres {
	return &UserRepositoryPostgres{
		db: db,
	}
}

func (r *UserRepositoryPostgres) CreateUser(newUser user.User) (user.User, error) {
	query := `INSERT INTO users (name, email) VALUES ($1, $2) RETURNING id, name, email`
	row := r.db.QueryRow(query, newUser.Username, newUser.Email)

	var createdUser user.User
	err := row.Scan(&createdUser.ID, &createdUser.Username, &createdUser.Email)
	if err != nil {
		return user.User{}, err
	}
	return createdUser, nil
}

func (r *UserRepositoryPostgres) GetUserByID(id string) (user.User, error) {
	query := `SELECT id, name, email FROM users WHERE id = $1`
	row := r.db.QueryRow(query, id)

	var foundUser user.User
	err := row.Scan(&foundUser.ID, &foundUser.Username, &foundUser.Email)
	if err != nil {
		if err == sql.ErrNoRows {
			return user.User{}, nil
		}
		return user.User{}, err
	}
	return foundUser, nil
}

func (r *UserRepositoryPostgres) GetAllUsers() ([]user.User, error) {
	query := `SELECT id, name, email FROM users`
	rows, err := r.db.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var users []user.User
	for rows.Next() {
		var u user.User
		if err := rows.Scan(&u.ID, &u.Username, &u.Email); err != nil {
			return nil, err
		}
		users = append(users, u)
	}
	return users, nil
}

func (r *UserRepositoryPostgres) UpdateUser(updatedUser user.User) (user.User, error) {
	query := `UPDATE users SET name = $1, email = $2 WHERE id = $3 RETURNING id, name, email`
	row := r.db.QueryRow(query, updatedUser.Username, updatedUser.Email, updatedUser.ID)

	var res user.User
	err := row.Scan(&res.ID, &res.Username, &res.Email)
	if err != nil {
		return user.User{}, err
	}
	return res, nil
}

func (r *UserRepositoryPostgres) DeleteUser(id string) error {
	query := `DELETE FROM users WHERE id = $1`
	_, err := r.db.Exec(query, id)
	if err != nil {
		return err
	}
	return nil
}
func (r *UserRepositoryPostgres) GetUserByEmail(email string) (user.User, error) {
	query := `SELECT id, name, email, password FROM users WHERE email = $1`
	row := r.db.QueryRow(query, email)

	var foundUser user.User
	err := row.Scan(&foundUser.ID, &foundUser.Username, &foundUser.Email, &foundUser.Password)
	if err != nil {
		if err == sql.ErrNoRows {
			return user.User{}, nil
		}
		return user.User{}, err
	}
	return foundUser, nil
}