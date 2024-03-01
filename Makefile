.PHONY: start
start:
	docker compose up -d $(ARGS)

.PHONY: stop
stop:
	docker compose stop

.PHONY: clean
clean:
	sudo rm -rf geth-logs
	sudo rm -rf /var/lib/blast

.PHONY: logs
logs:
	docker compose logs -n 200 -f

.PHONY: down
down:
	docker compose down