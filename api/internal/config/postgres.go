package config

import (
	"fmt"
	"os"

	_ "github.com/jackc/pgx/v5/stdlib"
	"github.com/jmoiron/sqlx"
)

func NewPostgresDB(connectionString string) *sqlx.DB {
	db, err := sqlx.Connect("pgx", connectionString)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Cannot connect to database: %s", err)
		os.Exit(1)
	}
	return db
}
