#!/bin/bash
# Cleanup script to stop and remove all containers and volumes

echo "==================================="
echo "Cleaning up Elastic Agent Test Environment"
echo "==================================="

# Use docker compose or docker-compose based on what's available
if docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
else
    DOCKER_COMPOSE="docker-compose"
fi

echo ""
echo "Stopping all containers..."
$DOCKER_COMPOSE down

echo ""
echo "Removing volumes (this will delete all data)..."
read -p "Are you sure you want to remove all volumes? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    $DOCKER_COMPOSE down -v
    echo "Volumes removed."
else
    echo "Volumes kept."
fi

echo ""
echo "Cleanup complete!"
