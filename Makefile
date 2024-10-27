include .env
export $(shell sed 's/=.*//' .env)

.PHONY: start
start:
	docker compose -p $(CHAIN_NAME) up -d $(ARGS)

.PHONY: stop
stop:
	docker compose -p $(CHAIN_NAME) stop

.PHONY: logs
logs:
	docker compose -p $(CHAIN_NAME) logs -n 200 -f

.PHONY: down
down:
	docker compose -p $(CHAIN_NAME) down

.PHONY: build
build:
	docker compose -p $(CHAIN_NAME) build
