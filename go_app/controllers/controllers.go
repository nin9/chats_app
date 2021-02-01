package controllers

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strconv"

	"github.com/gorilla/mux"
	"github.com/nin9/go_app/database"
	"github.com/nin9/go_app/producer"
)

func CreateChat(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	appToken := vars["token"]
	chatNumber, err := database.DB.Incr(database.Ctx, fmt.Sprintf("app_%s", appToken)).Result()
	if err != nil {
		respondWithError(w, http.StatusNotFound, "App not found")
	}
	producer.Producer.Enqueue("chats", "CreateChat", []string{appToken, strconv.FormatInt(chatNumber, 10)})
	data := struct {
		ChatNumber int64 `json:"chat_number"`
	}{chatNumber}
	respondWithJSON(w, http.StatusCreated, data)
}

func CreateMessage(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	appToken := vars["token"]
	chatNumber := vars["chat_number"]
	type MessageBody struct {
		Body string `json:"body"`
	}
	msgBody := &MessageBody{}
	decoder := json.NewDecoder(r.Body)
	if err := decoder.Decode(&msgBody); err != nil {
		respondWithError(w, http.StatusBadRequest, "Invalid request payload")
		return
	}
	defer r.Body.Close()
	msgNumber, err := database.DB.Incr(database.Ctx, fmt.Sprintf("app_%s_chat_%s", appToken, chatNumber)).Result()
	if err != nil {
		http.Error(w, "chat not found", http.StatusNotFound)
	}
	producer.Producer.Enqueue("messages", "CreateMessage", []string{appToken, chatNumber, strconv.FormatInt(msgNumber, 10), msgBody.Body})
	data := struct {
		MessageNumber int64 `json:"message_number"`
	}{msgNumber}
	respondWithJSON(w, http.StatusCreated, data)
}

func respondWithError(w http.ResponseWriter, code int, message string) {
	respondWithJSON(w, code, map[string]string{"error": message})
}

func respondWithJSON(w http.ResponseWriter, code int, payload interface{}) {
	response, _ := json.Marshal(payload)

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)
	w.Write(response)
}
