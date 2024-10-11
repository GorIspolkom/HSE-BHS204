.DEFAULT_GOAL := help
.PHONY: help up dev-up down test dev-down restart restart-dev logs logs-web logs-db ps clear

help: ## Подсказка по доступным командам
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-16s\033[0m %s\n", $$1, $$2}'

up: ## Поднять все контейнеры через docker-compose
	@docker compose up -d

dev-up: ## Поднять контейнер с СУБД через docker-compose
	@docker compose up -d db

down:  ## Удалить все контейнеры инстанса
	@docker compose down

dev-down: ## Удалить dev контейнер с СУБД
	@docker compose down db

restart: ## Перезапустить все контейнеры инстанса
	@docker compose stop
	@docker compose up -d

restart-dev: ## Перезапустить контейнер с СУБД
	@docker compose stop db
	@docker compose up -d

logs: ## Получить логи инсталляции
	@docker compose logs --tail=100 -f	

logs-web: ## Вывести логи веб-приложения
	@docker compose logs --tail=100 -f web_app

logs-db: ## Вывести логи контейнера с СУБД
	@docker compose logs --tail=100 -f db

ps: ## Получить список всех работающих контейнеров
	@docker compose ps

clear: ## Удалить все контейнеры инсталляции и все volume
	@docker compose rm -v
