package web

import (
	"app/db"
	"app/models"
	"encoding/json"
	"net/http"
)

func UserHandler(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case "GET":
		GetUsers(w, r)
	case "POST":
		CreateUser(w, r)
	case "DELETE":
		DeleteUser(w, r)
	default:
		w.WriteHeader(http.StatusMethodNotAllowed)
	}
}

func GetUsers(w http.ResponseWriter, r *http.Request) {
	var users []models.User
	db.DB.Find(&users)
	json.NewEncoder(w).Encode(users)
}

func CreateUser(w http.ResponseWriter, r *http.Request) {
	var user models.User
	json.NewDecoder(r.Body).Decode(&user)
	db.DB.Create(&user)
	json.NewEncoder(w).Encode(user)
}

func DeleteUser(w http.ResponseWriter, r *http.Request) {
	var user models.User
	json.NewDecoder(r.Body).Decode(&user)
	db.DB.Where("name = ? AND email = ?", &user.Name, &user.Email).Delete(&user)
}
