package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"strconv"

	"github.com/go-redis/redis/v8"
	"github.com/gorilla/mux"
	"github.com/jrallison/go-workers"
	"github.com/nin9/go_app/controllers"
	"github.com/nin9/go_app/database"
)

func setupRedis() error {
	var dbNo int
	dbNo, err := strconv.Atoi(os.Getenv("REDIS_DB"))
	if err != nil {
		dbNo = 0
	}
	database.DB = redis.NewClient(&redis.Options{
		Addr:     os.Getenv("REDIS_URL"),
		DB:       dbNo,
		PoolSize: 20,
	})
	if err := database.DB.Ping(database.Ctx).Err(); err != nil {
		return err
	}
	fmt.Println("Connected to redis")
	return nil
}

func setupWorkers() {
	workers.Configure(map[string]string{
		"process":  "publisher",
		"server":   os.Getenv("REDIS_URL"),
		"database": os.Getenv("REDIS_DB"),
		"pool":     "20",
	})
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
	setupWorkers()
	handleRequests()

	defer database.DB.Close()
}
