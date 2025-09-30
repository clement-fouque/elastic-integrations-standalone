#!/bin/bash
# Test script to verify the Elastic Agent integration setup

set -e

echo "==================================="
echo "Testing Elastic Agent Integration"
echo "==================================="

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Use docker compose or docker-compose based on what's available
if docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
else
    DOCKER_COMPOSE="docker-compose"
fi

# Function to test a service
test_service() {
    local service_name=$1
    local url=$2
    local expected_pattern=$3
    
    echo ""
    echo -n "Testing $service_name... "
    
    if curl -s "$url" | grep -q "$expected_pattern"; then
        echo -e "${GREEN}✓ PASSED${NC}"
        return 0
    else
        echo -e "${RED}✗ FAILED${NC}"
        return 1
    fi
}

# Test Elasticsearch
test_service "Elasticsearch" "http://localhost:9200" "cluster_name"

# Test Kibana
test_service "Kibana" "http://localhost:5601/api/status" "available"

# Test Fleet Server
test_service "Fleet Server" "http://localhost:8220/api/status" "HEALTHY"

# Test NGINX Sample
test_service "NGINX Sample" "http://localhost:8080/health" "healthy"

# Test Elasticsearch cluster health
echo ""
echo -n "Testing Elasticsearch cluster health... "
CLUSTER_HEALTH=$(curl -s http://localhost:9200/_cluster/health | grep -o '"status":"[^"]*"')
if [[ "$CLUSTER_HEALTH" == *"green"* ]] || [[ "$CLUSTER_HEALTH" == *"yellow"* ]]; then
    echo -e "${GREEN}✓ PASSED${NC} ($CLUSTER_HEALTH)"
else
    echo -e "${RED}✗ FAILED${NC} ($CLUSTER_HEALTH)"
fi

# Check Docker containers
echo ""
echo "Docker Container Status:"
$DOCKER_COMPOSE ps

# Check Elastic Agent enrollment
echo ""
echo "Checking Elastic Agent status..."
$DOCKER_COMPOSE logs elastic-agent | tail -20

echo ""
echo "==================================="
echo "Test Complete!"
echo "==================================="
echo ""
echo "To view detailed logs for a specific service:"
echo "  $DOCKER_COMPOSE logs [service-name]"
echo ""
echo "To generate test traffic to NGINX:"
echo "  curl http://localhost:8080"
echo "  curl http://localhost:8080/health"
echo ""
