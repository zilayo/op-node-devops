.PHONY: start
start:
	docker compose up -d $(ARGS)

.PHONY: stop
stop:
	docker compose stop

.PHONY: logs
logs:
	docker compose logs -n 200 -f

.PHONY: down
down:
	docker compose down