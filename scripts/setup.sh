#!/bin/bash
# Setup script for Elastic Agent Integration Testing

set -e

echo "==================================="
echo "Elastic Agent Integration Test Setup"
echo "==================================="

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed (try both docker-compose and docker compose)
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "Error: Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Use docker compose or docker-compose based on what's available
if docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
else
    DOCKER_COMPOSE="docker-compose"
fi

echo ""
echo "Step 1: Starting Elastic Stack..."
$DOCKER_COMPOSE up -d elasticsearch kibana

echo ""
echo "Step 2: Waiting for Elasticsearch to be ready..."
until curl -s http://localhost:9200/_cluster/health | grep -q '"status":"green"\|"status":"yellow"'; do
    echo "Waiting for Elasticsearch..."
    sleep 5
done
echo "Elasticsearch is ready!"

echo ""
echo "Step 3: Waiting for Kibana to be ready..."
until curl -s http://localhost:5601/api/status | grep -q '"level":"available"'; do
    echo "Waiting for Kibana..."
    sleep 5
done
echo "Kibana is ready!"

echo ""
echo "Step 4: Starting Fleet Server..."
$DOCKER_COMPOSE up -d fleet-server

echo ""
echo "Step 5: Waiting for Fleet Server to be ready..."
sleep 15
until curl -s http://localhost:8220/api/status | grep -q '"status":"HEALTHY"'; do
    echo "Waiting for Fleet Server..."
    sleep 5
done
echo "Fleet Server is ready!"

echo ""
echo "Step 6: Starting Elastic Agent..."
$DOCKER_COMPOSE up -d elastic-agent

echo ""
echo "Step 7: Starting sample applications..."
$DOCKER_COMPOSE up -d nginx-sample

echo ""
echo "==================================="
echo "Setup Complete!"
echo "==================================="
echo ""
echo "Access the following URLs:"
echo "  Elasticsearch: http://localhost:9200"
echo "  Kibana:        http://localhost:5601"
echo "  Fleet Server:  http://localhost:8220"
echo "  Sample NGINX:  http://localhost:8080"
echo ""
echo "To check the status of all services:"
echo "  $DOCKER_COMPOSE ps"
echo ""
echo "To view logs:"
echo "  $DOCKER_COMPOSE logs -f [service-name]"
echo ""
echo "To stop all services:"
echo "  $DOCKER_COMPOSE down"
echo ""
