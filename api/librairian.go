package main

import (
	"flag"
	"log"

	"github.com/joho/godotenv"
	"github.com/pidanou/librairian/internal/server"
)

func main() {
	err := godotenv.Load()
	if err != nil {
		log.Fatal("Error loading .env file")
	}

	port := flag.String("port", ":3001", "Port to serve")
	flag.Parse()

	s := server.New(*port)

	s.Start()
}
