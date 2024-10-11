package main

import (
	"app/db"
	"app/web"
	"fmt"
	"log"
	"net/http"
	"os"
	"strconv"
)

func CheckError(e error) {
	if e != nil {
		log.Fatal(e)
		panic(e)
	}
}

func main() {
	var POSTGRESQL_USER_FILE = os.Getenv("POSTGRES_USER_FILE")
	var POSTGRESQL_DATABASE_FILE = os.Getenv("POSTGRES_DATABASE_FILE")
	var POSTGRESQL_PASSWORD_FILE = os.Getenv("POSTGRES_PASSWORD_FILE")
	var POSTGRESQL_HOST = os.Getenv("POSTGRES_HOST")
	var POSTGRESQL_PORT = os.Getenv("POSTGRES_PORT")
	var APP_PORT = os.Getenv("APP_PORT")
	POSTGRESQL_PORT_INT, err := strconv.Atoi(POSTGRESQL_PORT)
	CheckError(err)
	POSTGRESQL_USER, err := os.ReadFile(POSTGRESQL_USER_FILE)
	CheckError(err)
	POSTGRESQL_DATABASE, err := os.ReadFile(POSTGRESQL_DATABASE_FILE)
	CheckError(err)
	POSTGRESQL_PASSWORD, err := os.ReadFile(POSTGRESQL_PASSWORD_FILE)
	CheckError(err)
	var APP_LISTEN_PORT = fmt.Sprintf(":%s", APP_PORT)
	db.ConnectDB(string(POSTGRESQL_USER), string(POSTGRESQL_DATABASE), string(POSTGRESQL_PASSWORD), POSTGRESQL_HOST, POSTGRESQL_PORT_INT)
	http.HandleFunc("/users", web.UserHandler)
	log.Fatal(http.ListenAndServe(APP_LISTEN_PORT, nil))
}
