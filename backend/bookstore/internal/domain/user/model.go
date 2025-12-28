package user

import (
	"encoding/json"
	"errors"
	"strconv"
	"time"
)

type User struct {
	ID             int        `json:"id"`
	Username       string     `json:"username"`
	Email          string     `json:"email"`
	PasswordHash   string     `json:"passwordHash"`
	ProfileImage   *string    `json:"profileImage,omitempty"`
	CreatedAt      time.Time  `json:"createdAt"`
	UpdatedAt      time.Time  `json:"updatedAt"`
	BooksReadCount int        `json:"booksReadCount"`
	ReadingStreak  int        `json:"readingStreak"`
	LastReadDate   *time.Time `json:"lastReadDate,omitempty"`
	Points         int        `json:"points"`
}

func NewUser(
	id int,
	username, email, passwordHash string,
	profileImage *string,
	createdAt, updatedAt time.Time,
	booksReadCount, readingStreak, points int,
	lastReadDate *time.Time,
) *User {
	now := time.Now()

	// Defaults for timestamps
	if createdAt.IsZero() {
		createdAt = now
	}
	if updatedAt.IsZero() {
		updatedAt = now
	}

	// Normalize optional profile image
	if profileImage != nil && *profileImage == "" {
		profileImage = nil
	}

	// Normalize optional last read date
	if lastReadDate != nil && lastReadDate.IsZero() {
		lastReadDate = nil
	}

	return &User{
		ID:             id,
		Username:       username,
		Email:          email,
		PasswordHash:   passwordHash,
		ProfileImage:   profileImage,
		CreatedAt:      createdAt,
		UpdatedAt:      updatedAt,
		BooksReadCount: booksReadCount,
		ReadingStreak:  readingStreak,
		LastReadDate:   lastReadDate,
		Points:         points,
	}
}

// Supports alternate keys and date formats similar to the Dart model.
func (u *User) UnmarshalJSON(data []byte) error {
	var raw map[string]any
	if err := json.Unmarshal(data, &raw); err != nil {
		return err
	}

	// id: can be string or int
	switch v := raw["id"].(type) {
	case string:
		id, err := strconv.Atoi(v)
		if err != nil {
			return err
		}
		u.ID = id
	case float64:
		u.ID = int(v)
	default:
		return errors.New("id is required")
	}

	// username: prefer 'username', fallback to 'name'
	if val, ok := raw["username"]; ok && val != nil {
		u.Username = toString(val)
	} else if val, ok := raw["name"]; ok && val != nil {
		u.Username = toString(val)
	}

	u.Email = toString(raw["email"])

	// passwordHash: 'password' or 'password_hash'
	if val, ok := raw["password"]; ok && val != nil {
		u.PasswordHash = toString(val)
	} else if val, ok := raw["password_hash"]; ok && val != nil {
		u.PasswordHash = toString(val)
	} else {
		u.PasswordHash = ""
	}

	// profileImage: 'profileImage' or 'profile_image'
	if val, ok := raw["profileImage"]; ok && val != nil {
		s := toString(val)
		u.ProfileImage = &s
	} else if val, ok := raw["profile_image"]; ok && val != nil {
		s := toString(val)
		u.ProfileImage = &s
	}

	// createdAt: 'createdAt' or 'created_at'
	ca := firstNonNil(raw, "createdAt", "created_at")
	t, err := parseDate(ca)
	if err != nil {
		return err
	}
	u.CreatedAt = t

	// updatedAt: 'updatedAt' or 'updated_at'
	ua := firstNonNil(raw, "updatedAt", "updated_at")
	t, err = parseDate(ua)
	if err != nil {
		return err
	}
	u.UpdatedAt = t

	// booksReadCount: 'booksReadCount' or 'books_read_count'
	u.BooksReadCount = toIntDefault(firstNonNil(raw, "booksReadCount", "books_read_count"), 0)

	// readingStreak: 'readingStreak' or 'reading_streak'
	u.ReadingStreak = toIntDefault(firstNonNil(raw, "readingStreak", "reading_streak"), 0)

	// lastReadDate: optional 'lastReadDate' or 'last_read_date'
	lrd := firstNonNil(raw, "lastReadDate", "last_read_date")
	if lrd != nil {
		if tt, err := tryParseDate(lrd); err == nil && tt != nil {
			u.LastReadDate = tt
		}
	}

	// points
	u.Points = toIntDefault(raw["points"], 0)

	return nil
}

func (u User) MarshalJSON() ([]byte, error) {
	type alias struct {
		ID             int        `json:"id"`
		Username       string     `json:"username"`
		Email          string     `json:"email"`
		PasswordHash   string     `json:"passwordHash"`
		ProfileImage   *string    `json:"profile_image,omitempty"`
		CreatedAt      string     `json:"created_at"`
		UpdatedAt      string     `json:"updated_at"`
		BooksReadCount int        `json:"books_read_count"`
		ReadingStreak  int        `json:"reading_streak"`
		LastReadDate   *string    `json:"last_read_date,omitempty"`
		Points         int        `json:"points"`
	}
	var last *string
	if u.LastReadDate != nil {
		s := u.LastReadDate.Format(time.RFC3339Nano)
		last = &s
	}
	return json.Marshal(alias{
		ID:             u.ID,
		Username:       u.Username,
		Email:          u.Email,
		PasswordHash:   u.PasswordHash,
		ProfileImage:   u.ProfileImage,
		CreatedAt:      u.CreatedAt.Format(time.RFC3339Nano),
		UpdatedAt:      u.UpdatedAt.Format(time.RFC3339Nano),
		BooksReadCount: u.BooksReadCount,
		ReadingStreak:  u.ReadingStreak,
		LastReadDate:   last,
		Points:         u.Points,
	})
}

func toString(v any) string {
	switch x := v.(type) {
	case string:
		return x
	case float64:
		return strconv.FormatFloat(x, 'f', -1, 64)
	case json.Number:
		return x.String()
	default:
		return ""
	}
}

func toIntDefault(v any, def int) int {
	switch x := v.(type) {
	case float64:
		return int(x)
	case int:
		return x
	case int64:
		return int(x)
	case string:
		if x == "" {
			return def
		}
		if n, err := strconv.Atoi(x); err == nil {
			return n
		}
		return def
	default:
		return def
	}
}

func firstNonNil(m map[string]any, keys ...string) any {
	for _, k := range keys {
		if v, ok := m[k]; ok && v != nil {
			return v
		}
	}
	return nil
}

func parseDate(v any) (time.Time, error) {
	switch x := v.(type) {
	case time.Time:
		return x, nil
	case float64:
		// milliseconds since epoch
		return time.Unix(0, int64(x)*int64(time.Millisecond)), nil
	case int64:
		return time.Unix(0, x*int64(time.Millisecond)), nil
	case int:
		return time.Unix(0, int64(x)*int64(time.Millisecond)), nil
	case string:
		return time.Parse(time.RFC3339, x)
	default:
		return time.Time{}, errors.New("invalid date value")
	}
}

func tryParseDate(v any) (*time.Time, error) {
	if v == nil {
		return nil, nil
	}
	t, err := parseDate(v)
	if err != nil {
		return nil, nil
	}
	return &t, nil
}