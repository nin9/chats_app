package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"strconv"

	workers "github.com/digitalocean/go-workers2"
	"github.com/go-redis/redis/v8"
	"github.com/gorilla/mux"
	"github.com/nin9/go_app/controllers"
	"github.com/nin9/go_app/database"
	"github.com/nin9/go_app/producer"
)

func setupRedis() error {
	var dbNo int
	dbNo, err := strconv.Atoi(os.Getenv("REDIS_DB"))
	if err != nil {
		dbNo = 0
	}
	database.DB = redis.NewClient(&redis.Options{
		Addr: os.Getenv("REDIS_URL"),
		DB:   dbNo,
	})
	if err := database.DB.Ping(database.Ctx).Err(); err != nil {
		return err
	}
	fmt.Println("Connected to redis")
	return nil
}

func setupProducer() {
	var dbNo int
	dbNo, err := strconv.Atoi(os.Getenv("REDIS_DB"))
	if err != nil {
		dbNo = 0
	}
	workersProducer, err := workers.NewProducer(workers.Options{
		ServerAddr: os.Getenv("REDIS_URL"),
		Database:   dbNo,
		ProcessID:  "go_producer",
	})

	producer.Producer = workersProducer
	if err != nil {
		log.Fatalf("Failed to setup producer: %s", err.Error())
	}
}

func handleRequests() {
	r := mux.NewRouter()
	r.HandleFunc("/apps/{token}/chats", controllers.CreateChat).Methods("POST")
	r.HandleFunc("/apps/{token}/chats/{chat_number}/messages", controllers.CreateMessage).Methods("POST")
	fmt.Println("Server started")
	log.Fatal(http.ListenAndServe(":8000", r))
}

func main() {
	database.Ctx = context.TODO()
	err := setupRedis()
	if err != nil {
		log.Fatalf("Failed to connect to redis: %s", err.Error())
	}
	setupProducer()
	handleRequests()

	defer database.DB.Close()
}
