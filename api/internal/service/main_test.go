package service

import (
	"os"
	"testing"

	"github.com/jmoiron/sqlx"
	"github.com/pidanou/librairian/internal/config"
	"github.com/pidanou/librairian/internal/repository"
)

var testPostgres *sqlx.DB
var testArchiveRespository *repository.PostgresArchiveRepository
var testArchiveService *ArchiveService

func TestMain(m *testing.M) {
	testPostgres = config.NewPostgresDB(os.Getenv("POSTGRES_CONNECTION_STRING"))
	testArchiveRespository = repository.NewPostgresArchiveRepository(testPostgres)
	testArchiveService = NewArchiveService(testArchiveRespository)

	code := m.Run()

	testPostgres.Close()
	os.Exit(code)
}
