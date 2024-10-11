package db

import (
	"app/models"
	"fmt"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var DB *gorm.DB

func ConnectDB(postgresql_user string, postgresql_database string, postgresql_password string, postgresql_host string, postgresql_port int) {
	var err error
	conn_data := fmt.Sprintf("host=%s port=%d user=%s password=%s dbname=%s sslmode=disable", postgresql_host, postgresql_port, postgresql_user, postgresql_password, postgresql_database)
	DB, err = gorm.Open(postgres.Open(conn_data), &gorm.Config{})
	if err != nil {
		panic("No connect to DB")
	}
	DB.AutoMigrate(&models.User{})
}
