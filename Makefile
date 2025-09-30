.PHONY: help setup start stop restart status logs clean test health

# Detect docker compose command
DOCKER_COMPOSE := $(shell docker compose version > /dev/null 2>&1 && echo "docker compose" || echo "docker-compose")

# Default target
help:
	@echo "Elastic Agent Integration Test Environment"
	@echo ""
	@echo "Available targets:"
	@echo "  make setup     - Setup and start all services"
	@echo "  make start     - Start all services"
	@echo "  make stop      - Stop all services"
	@echo "  make restart   - Restart all services"
	@echo "  make status    - Show status of all services"
	@echo "  make logs      - Follow logs from all services"
	@echo "  make test      - Run health checks on all services"
	@echo "  make health    - Check health of Elasticsearch cluster"
	@echo "  make clean     - Stop and remove all containers and volumes"
	@echo ""
	@echo "Service-specific targets:"
	@echo "  make logs-elasticsearch  - View Elasticsearch logs"
	@echo "  make logs-kibana        - View Kibana logs"
	@echo "  make logs-fleet         - View Fleet Server logs"
	@echo "  make logs-agent         - View Elastic Agent logs"
	@echo "  make logs-nginx         - View NGINX logs"

# Setup and start all services
setup:
	@./scripts/setup.sh

# Start all services
start:
	@$(DOCKER_COMPOSE) up -d
	@echo "Services starting... Use 'make status' to check progress"

# Stop all services
stop:
	@$(DOCKER_COMPOSE) down
	@echo "All services stopped"

# Restart all services
restart: stop start

# Show status of all services
status:
	@$(DOCKER_COMPOSE) ps

# Follow logs from all services
logs:
	@$(DOCKER_COMPOSE) logs -f

# Service-specific logs
logs-elasticsearch:
	@$(DOCKER_COMPOSE) logs -f elasticsearch

logs-kibana:
	@$(DOCKER_COMPOSE) logs -f kibana

logs-fleet:
	@$(DOCKER_COMPOSE) logs -f fleet-server

logs-agent:
	@$(DOCKER_COMPOSE) logs -f elastic-agent

logs-nginx:
	@$(DOCKER_COMPOSE) logs -f nginx-sample

# Run health checks
test:
	@./scripts/test.sh

# Check Elasticsearch cluster health
health:
	@echo "Elasticsearch Cluster Health:"
	@curl -s http://localhost:9200/_cluster/health?pretty || echo "Elasticsearch not available"
	@echo ""
	@echo "Kibana Status:"
	@curl -s http://localhost:5601/api/status | grep -o '"level":"[^"]*"' || echo "Kibana not available"
	@echo ""
	@echo "Fleet Server Status:"
	@curl -s http://localhost:8220/api/status | grep -o '"status":"[^"]*"' || echo "Fleet Server not available"

# Clean up everything
clean:
	@./scripts/cleanup.sh

# Generate test traffic to NGINX
traffic:
	@echo "Generating test traffic to NGINX..."
	@for i in 1 2 3 4 5 6 7 8 9 10; do \
		curl -s http://localhost:8080 > /dev/null && echo "Request $$i: OK"; \
		sleep 1; \
	done
	@echo "Test traffic generated"

# Open Kibana in browser (Linux/WSL)
kibana:
	@echo "Opening Kibana at http://localhost:5601"
	@which xdg-open > /dev/null && xdg-open http://localhost:5601 || echo "Please open http://localhost:5601 in your browser"
