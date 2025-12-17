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
	query := `
		INSERT INTO users (
			username,
			email,
			password_hash,
			profile_image,
			created_at,
			updated_at,
			books_read_count,
			reading_streak,
			last_read_date,
			points
		)
		VALUES ($1, $2, $3, $4, NOW(), NOW(), $5, $6, $7, $8)
		RETURNING
			id,
			username,
			email,
			password_hash,
			profile_image,
			created_at,
			updated_at,
			books_read_count,
			reading_streak,
			last_read_date,
			points
	`
	row := r.db.QueryRow(
		query,
		newUser.Username,
		newUser.Email,
		newUser.PasswordHash,
		newUser.ProfileImage,
		newUser.BooksReadCount,
		newUser.ReadingStreak,
		newUser.LastReadDate,
		newUser.Points,
	)

	var createdUser user.User
	err := row.Scan(
		&createdUser.ID,
		&createdUser.Username,
		&createdUser.Email,
		&createdUser.PasswordHash,
		&createdUser.ProfileImage,
		&createdUser.CreatedAt,
		&createdUser.UpdatedAt,
		&createdUser.BooksReadCount,
		&createdUser.ReadingStreak,
		&createdUser.LastReadDate,
		&createdUser.Points,
	)
	if err != nil {
		return user.User{}, err
	}
	return createdUser, nil
}

func (r *UserRepositoryPostgres) GetUserByID(id string) (user.User, error) {
	query := `
		SELECT
			id,
			username,
			email,
			password_hash,
			profile_image,
			created_at,
			updated_at,
			books_read_count,
			reading_streak,
			last_read_date,
			points
		FROM users
		WHERE id = $1
	`
	row := r.db.QueryRow(query, id)

	var foundUser user.User
	err := row.Scan(
		&foundUser.ID,
		&foundUser.Username,
		&foundUser.Email,
		&foundUser.PasswordHash,
		&foundUser.ProfileImage,
		&foundUser.CreatedAt,
		&foundUser.UpdatedAt,
		&foundUser.BooksReadCount,
		&foundUser.ReadingStreak,
		&foundUser.LastReadDate,
		&foundUser.Points,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return user.User{}, nil
		}
		return user.User{}, err
	}
	return foundUser, nil
}

func (r *UserRepositoryPostgres) GetAllUsers() ([]user.User, error) {
	query := `
		SELECT
			id,
			username,
			email,
			password_hash,
			profile_image,
			created_at,
			updated_at,
			books_read_count,
			reading_streak,
			last_read_date,
			points
		FROM users
	`
	rows, err := r.db.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var users []user.User
	for rows.Next() {
		var u user.User
		if err := rows.Scan(
			&u.ID,
			&u.Username,
			&u.Email,
			&u.PasswordHash,
			&u.ProfileImage,
			&u.CreatedAt,
			&u.UpdatedAt,
			&u.BooksReadCount,
			&u.ReadingStreak,
			&u.LastReadDate,
			&u.Points,
		); err != nil {
			return nil, err
		}
		users = append(users, u)
	}
	return users, nil
}

func (r *UserRepositoryPostgres) UpdateUser(updatedUser user.User) (user.User, error) {
	query := `
		UPDATE users
		SET
			username = $1,
			email = $2,
			password_hash = $3,
			profile_image = $4,
			books_read_count = $5,
			reading_streak = $6,
			last_read_date = $7,
			points = $8,
			updated_at = NOW()
		WHERE id = $9
		RETURNING
			id,
			username,
			email,
			password_hash,
			profile_image,
			created_at,
			updated_at,
			books_read_count,
			reading_streak,
			last_read_date,
			points
	`
	row := r.db.QueryRow(
		query,
		updatedUser.Username,
		updatedUser.Email,
		updatedUser.PasswordHash,
		updatedUser.ProfileImage,
		updatedUser.BooksReadCount,
		updatedUser.ReadingStreak,
		updatedUser.LastReadDate,
		updatedUser.Points,
		updatedUser.ID,
	)

	var res user.User
	err := row.Scan(
		&res.ID,
		&res.Username,
		&res.Email,
		&res.PasswordHash,
		&res.ProfileImage,
		&res.CreatedAt,
		&res.UpdatedAt,
		&res.BooksReadCount,
		&res.ReadingStreak,
		&res.LastReadDate,
		&res.Points,
	)
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
	query := `
		SELECT
			id,
			username,
			email,
			password_hash,
			profile_image,
			created_at,
			updated_at,
			books_read_count,
			reading_streak,
			last_read_date,
			points
		FROM users
		WHERE email = $1
	`
	row := r.db.QueryRow(query, email)

	var foundUser user.User
	err := row.Scan(
		&foundUser.ID,
		&foundUser.Username,
		&foundUser.Email,
		&foundUser.PasswordHash,
		&foundUser.ProfileImage,
		&foundUser.CreatedAt,
		&foundUser.UpdatedAt,
		&foundUser.BooksReadCount,
		&foundUser.ReadingStreak,
		&foundUser.LastReadDate,
		&foundUser.Points,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return user.User{}, nil
		}
		return user.User{}, err
	}
	return foundUser, nil
}