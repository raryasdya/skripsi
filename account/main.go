package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
)

type AccountResponse struct {
	Name   string `json:"name"`
	Status string `json:"status"`
	Source string `json:"source"`
}

func main() {
	http.HandleFunc("/", handler)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8081"
	}

	log.Printf("Listening on localhost:%s", port)
	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%s", port), nil))
}

func handler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	acc := AccountResponse{
		Name:   "Raryasdya",
		Status: "PREMIUM",
		Source: "account-service",
	}

	json.NewEncoder(w).Encode(acc)
}
