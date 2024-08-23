package server

import (
	"os"

	echojwt "github.com/labstack/echo-jwt/v4"
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
	"github.com/pidanou/librairian/internal/config"
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

	supabasePostgres := config.NewPostgresDB(os.Getenv("POSTGRES_CONNECTION_STRING"))

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
	e.Use(middleware.CORSWithConfig(middleware.CORSConfig{
		AllowOrigins: []string{"https://app.librairian.io"},
	}))

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

	api.GET("/items", h.GetItems)
	api.POST("/items", h.PostItems)
	api.PUT("/item", h.PutItem)
	api.GET("/item/:id", h.GetItemById)
	api.DELETE("/item/:id", h.DeleteItem)
	api.PATCH("/item/:id/metadata", h.PatchItemMetadata)
	api.GET("/items/matches", h.GetMatches)

	api.GET("/storage", h.GetStorage)
	api.POST("/storage", h.PostStorage)
	api.DELETE("/storage/:id", h.DeleteStorage)
	api.PUT("/storage", h.PutStorage)

	e.Start(s.Port)

}
