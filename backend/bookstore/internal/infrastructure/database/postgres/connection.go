package postgres

import (
    "database/sql"
    "log"
    "os"

    _ "github.com/jackc/pgx/v5/stdlib"
    "github.com/joho/godotenv"
)

func NewPostgresDBConnection() *sql.DB {
    // Load .env
    if err := godotenv.Load(); err != nil {
        log.Println("Warning: .env file not found")
    }

    dbURL := os.Getenv("DATABASE_URL")
    if dbURL == "" {
        log.Fatal("DATABASE_URL is not set in environment")
    }

    // Open using "pgx" driver
    db, err := sql.Open("pgx", dbURL)
    if err != nil {
        log.Fatal("Failed to open database:", err)
    }

    if err := db.Ping(); err != nil {
        log.Fatal("Failed to ping the database:", err)
    }

    log.Println("✅ Connected to PostgreSQL on Neon!")
    return db
}
