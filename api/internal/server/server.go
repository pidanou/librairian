package server

import (
	"os"

	"github.com/labstack/echo/v4"
	"github.com/pidanou/librairian/internal/datastore"
	"github.com/pidanou/librairian/internal/handler"
	"github.com/pidanou/librairian/internal/repository"
	"github.com/pidanou/librairian/internal/service"
)

type Server struct {
	Port string
}

func New(port string) *Server {
	return &Server{Port: port}
}

func (s *Server) Start() {

	supabasePostgres := datastore.NewPostgresDB(os.Getenv("POSTGRES_CONNECTION_STRING"))

	archiveRepository := repository.NewPostgresArchiveRepository(supabasePostgres)
	embeddingRepository := repository.NewOpenaiEmbeddingRepository(os.Getenv("OPENAI_API_KEY"), "text-embedding-3-small")
	similarityRepository := repository.NewPgvectorSimilarityRepository(supabasePostgres)

	archiveService := service.NewFileService(archiveRepository)
	embeddingService := service.NewEmbeddingService(embeddingRepository)
	similarityService := service.NewSimilarityService(similarityRepository)

	h := handler.New(archiveService, embeddingService, similarityService)

	e := echo.New()
	e.HideBanner = true

	api := e.Group("/api/v1")
	api.POST("/file", h.PostFile)
	api.GET("/file/:id", h.GetFileById)

	api.GET("/matches", h.GetMatches)

	e.Start(s.Port)

}
