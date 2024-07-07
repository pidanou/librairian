package server

import (
	"github.com/labstack/echo/v4"
	"github.com/pidanou/librairian/internal/handler"
)

type Server struct {
	Port string
}

func New(port string) *Server {
	return &Server{Port: port}
}

func (s *Server) Start() {

	h := handler.New()

	e := echo.New()
	e.HideBanner = true

	e.POST("/document", h.PostDocument)

	e.Start(s.Port)

}
