package main

import (
	"flag"

	"github.com/pidanou/librairian/internal/server"
)

func main() {
	port := flag.String("port", ":3001", "Port to serve")
	flag.Parse()

	s := server.New(*port)

	s.Start()
}
