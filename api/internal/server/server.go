package server

import (
	"net/http"
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
	attachmentRepository := repository.NewPostgresAttachmentRepository(supabasePostgres)
	billingRepository := repository.NewPostgresBillingRepository(supabasePostgres)

	embeddingService := service.NewEmbeddingService(os.Getenv("SUPABASE_ANON_KEY"), os.Getenv("SUPABASE_URL"), "text-embedding-3-small")
	similarityService := service.NewSimilarityService(supabasePostgres)
	imageCaptionService := service.NewImageCaptionsService(os.Getenv("GCP_PROJECT_ID"), os.Getenv("GCP_SERVICE_ACCOUNT_KEY"), os.Getenv("GCP_LOCATION"))
	imageArchiveService := service.NewSupabaseImageArchiveService(os.Getenv("SUPABASE_PROJECT_ID"), os.Getenv("SUPABASE_SERVICE_KEY"))
	billingService := service.NewPostgresBillingService(billingRepository)

	archiveService := service.NewArchiveService(archiveRepository, embeddingService, similarityService, billingService)
	attachmentService := service.NewAttachmentService(attachmentRepository, embeddingService, imageCaptionService, imageArchiveService, billingService)

	h := handler.New(archiveService, attachmentService)

	e := echo.New()
	e.HideBanner = true

	e.Use(middleware.Logger())
	e.Use(middleware.Recover())
	e.Use(middleware.CORSWithConfig(middleware.CORSConfig{
		AllowOrigins: []string{"https://app.librairian.io", "http://localhost:3000"},
	}))

	e.GET("/health", func(c echo.Context) error { return c.String(http.StatusOK, "ok") })
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
	api.POST("/item", h.PostItem)
	api.PUT("/item", h.PutItem)
	api.PATCH("/item/:id", h.PatchItem)
	api.GET("/item/:id", h.GetItemByID)
	api.DELETE("/item/:id", h.DeleteItem)
	api.GET("/item/matches", h.GetMatches)
	api.GET("/item/:id/attachments", h.GetItemAttachments)
	api.POST("/item/:id/location", h.PostItemLocation)

	api.DELETE("/location/:id", h.DeleteItemLocation)

	api.POST("/attachments", h.PostAttachments)
	api.DELETE("/attachment/:id", h.DeleteAttachmentByID)

	api.GET("/storage", h.GetStoragesByUserID)
	api.GET("/storage/:id", h.GetStorageByID)
	api.POST("/storage", h.PostStorage)
	api.DELETE("/storage/:id", h.DeleteStorage)
	api.PUT("/storage", h.PutStorage)

	e.Start(s.Port)

}
