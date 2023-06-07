package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"
)

const accountURL = "http://account-service:8081/account"

type MembershipResponse struct {
	Name   string `json:"name"`
	Status string `json:"status"`
	Source string `json:"source"`
}

type Account struct {
	Name   string `json:"name"`
	Status string `json:"status"`
	Source string `json:"source"`
}

type Error struct {
	Error string `json:"error"`
}

func main() {
	http.HandleFunc("/", handler)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Listening on localhost:%s", port)
	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%s", port), nil))
}

func handler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	var client = &http.Client{Timeout: 10 * time.Second}
	req, err := http.NewRequest("GET", accountURL, nil)
	if err != nil {
		json.NewEncoder(w).Encode(Error{
			Error: err.Error(),
		})
		return
	}

	resp, err := client.Do(req)
	if err != nil {
		json.NewEncoder(w).Encode(Error{
			Error: err.Error(),
		})
		return
	}

	var account Account

	defer resp.Body.Close()
	json.NewDecoder(resp.Body).Decode(&account)

	mem := MembershipResponse{
		Name:   account.Name,
		Status: account.Status,
		Source: "membership-service",
	}

	json.NewEncoder(w).Encode(mem)
}
