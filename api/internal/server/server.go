package server

import (
	"os"

	echojwt "github.com/labstack/echo-jwt/v4"
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
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

	archiveService := service.NewArchiveService(archiveRepository)
	embeddingService := service.NewEmbeddingService(embeddingRepository)
	similarityService := service.NewSimilarityService(similarityRepository)

	h := handler.New(archiveService, embeddingService, similarityService)

	e := echo.New()
	e.HideBanner = true

	e.Use(middleware.Logger())
	e.Use(middleware.Recover())

	api := e.Group("/api/v1")
	api.Use(echojwt.WithConfig(echojwt.Config{
		SigningKey: []byte(os.Getenv("JWT_SECRET")),
		Skipper: func(c echo.Context) bool {
			if c.Path() == "/api/v1/*" {
				return true
			}
			return false
		},
	}))

	api.POST("/file", h.PostFile)
	api.PUT("/file", h.PutFile)
	api.GET("/file/:id", h.GetFileById)
	api.DELETE("/file/:id", h.DeleteFile)
	api.PATCH("/file/:id/metadata", h.PatchFileMetadata)
	api.GET("/file/matches", h.GetMatches)

	e.Start(s.Port)

}
