# Variablen
DOCKER_COMPOSE_FILE = docker-compose.yml
NETWORK_NAME = mitm_net

# Docker Compose Befehle
up: create_network
	docker-compose -f $(DOCKER_COMPOSE_FILE) up -d --build

down:
	docker-compose -f $(DOCKER_COMPOSE_FILE) down

build:
	docker-compose -f $(DOCKER_COMPOSE_FILE) build --no-cache

stop:
	docker-compose -f $(DOCKER_COMPOSE_FILE) stop

# Erweiterte Cleanup-Funktion
clean: down
	@echo "Führe erweiterte Bereinigung durch..."
	@echo "Stoppe alle Container im Netzwerk..."
	@docker ps -q --filter network=$(NETWORK_NAME) | xargs -r docker stop
	@echo "Entferne alle Container im Netzwerk..."
	@docker ps -aq --filter network=$(NETWORK_NAME) | xargs -r docker rm -f
	@echo "Warte kurz auf Netzwerk-Cleanup..."
	@sleep 2
	@echo "Entferne Netzwerk..."
	@docker network rm $(NETWORK_NAME) || \
	(docker network disconnect -f $(NETWORK_NAME) $$(docker network inspect -f '{{range .Containers}}{{.Name}} {{end}}' $(NETWORK_NAME) 2>/dev/null) 2>/dev/null; \
	docker network rm $(NETWORK_NAME))
	@echo "Entferne verwaiste Volumes..."
	docker volume prune -f

create_network:
	@if [ -z "$$(docker network ls --filter name=$(NETWORK_NAME) -q)" ]; then \
		echo "Erstelle Netzwerk $(NETWORK_NAME)..."; \
		docker network create $(NETWORK_NAME); \
	else \
		echo "Netzwerk $(NETWORK_NAME) existiert bereits."; \
	fi

test_client:
	@docker exec -it bob sh

test_ftp:
	@docker exec -it bob sh -c "ftp 192.168.1.10 21"

test_server:
	@docker exec -it mary sh

help:
	@echo "Verfügbare Befehle:"
	@echo "  up                    - Container starten (kein Cache)"
	@echo "  down                  - Container stoppen und entfernen"
	@echo "  build                 - Container bauen (kein Cache)"
	@echo "  stop                  - Container stoppen"
	@echo "  test_ftp              - FTP-Dienste testen"
	@echo "  test_no_inquisitor    - Test ohne Inquisitor"
	@echo "  test_with_inquisitor  - Test mit Inquisitor"
	@echo "  clean                 - Alle Daten und Container entfernen (erweitert)"
