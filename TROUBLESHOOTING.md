# Troubleshooting Guide

This guide helps you resolve common issues with the Elastic Agent integration testing environment.

## Table of Contents

1. [Services Not Starting](#services-not-starting)
2. [Elasticsearch Issues](#elasticsearch-issues)
3. [Kibana Issues](#kibana-issues)
4. [Fleet Server Issues](#fleet-server-issues)
5. [Elastic Agent Issues](#elastic-agent-issues)
6. [Network Issues](#network-issues)
7. [Performance Issues](#performance-issues)
8. [Docker Issues](#docker-issues)

---

## Services Not Starting

### Problem: Docker Compose fails to start

**Symptoms:**
- Error messages when running `docker-compose up`
- Services exit immediately after starting

**Solutions:**

1. Check Docker daemon is running:
   ```bash
   docker ps
   ```

2. Check Docker Compose version:
   ```bash
   docker-compose version
   # Should be v2.0 or higher
   ```

3. Check for port conflicts:
   ```bash
   # Check if ports are already in use
   netstat -tuln | grep -E '9200|5601|8220|8080'
   ```

4. Check logs for specific service:
   ```bash
   docker-compose logs [service-name]
   ```

---

## Elasticsearch Issues

### Problem: Elasticsearch fails to start

**Symptoms:**
- Container exits with code 137 (out of memory)
- Container exits with code 1 (configuration error)

**Solutions:**

1. **Out of Memory Error:**
   
   Increase Docker memory allocation:
   ```bash
   # Linux: Edit /etc/docker/daemon.json
   # Windows/Mac: Docker Desktop Settings → Resources
   
   # Minimum: 4GB RAM
   # Recommended: 8GB RAM
   ```

2. **Insufficient virtual memory:**
   ```bash
   # Linux only
   sudo sysctl -w vm.max_map_count=262144
   
   # Make it permanent
   echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
   ```

3. **Check Elasticsearch logs:**
   ```bash
   docker-compose logs elasticsearch | tail -50
   ```

### Problem: Elasticsearch is slow or unresponsive

**Symptoms:**
- Queries take a long time
- Health check timeouts

**Solutions:**

1. Check cluster health:
   ```bash
   curl http://localhost:9200/_cluster/health?pretty
   ```

2. Check disk space:
   ```bash
   docker exec elasticsearch df -h
   ```

3. Increase JVM heap size (edit docker-compose.yml):
   ```yaml
   environment:
     - "ES_JAVA_OPTS=-Xms1g -Xmx1g"
   ```

---

## Kibana Issues

### Problem: Kibana stuck on "Kibana server is not ready yet"

**Symptoms:**
- White screen with loading message
- Cannot access Kibana UI

**Solutions:**

1. Wait longer (initial startup can take 2-3 minutes):
   ```bash
   docker-compose logs -f kibana
   ```

2. Check Elasticsearch connectivity:
   ```bash
   docker exec kibana curl -s http://elasticsearch:9200
   ```

3. Restart Kibana:
   ```bash
   docker-compose restart kibana
   ```

4. Check for disk space issues:
   ```bash
   docker exec kibana df -h
   ```

### Problem: Cannot access Kibana at localhost:5601

**Symptoms:**
- Connection refused
- Timeout errors

**Solutions:**

1. Check if Kibana container is running:
   ```bash
   docker-compose ps kibana
   ```

2. Check port mapping:
   ```bash
   docker port kibana
   ```

3. Check firewall rules:
   ```bash
   # Linux
   sudo ufw status
   
   # Check if port 5601 is allowed
   ```

---

## Fleet Server Issues

### Problem: Fleet Server not starting

**Symptoms:**
- Container exits or restarts continuously
- Health check fails

**Solutions:**

1. Check if Elasticsearch and Kibana are healthy:
   ```bash
   curl http://localhost:9200/_cluster/health
   curl http://localhost:5601/api/status
   ```

2. Check Fleet Server logs:
   ```bash
   docker-compose logs -f fleet-server
   ```

3. Verify service token (in docker-compose.yml):
   ```yaml
   environment:
     - FLEET_SERVER_SERVICE_TOKEN=${FLEET_SERVER_SERVICE_TOKEN:-changeme}
   ```

4. Reset Fleet Server:
   ```bash
   docker-compose stop fleet-server
   docker-compose rm -f fleet-server
   docker-compose up -d fleet-server
   ```

### Problem: Fleet Server status shows "DEGRADED"

**Solutions:**

1. Check connectivity to Elasticsearch:
   ```bash
   docker exec fleet-server curl -s http://elasticsearch:9200
   ```

2. Check for errors in logs:
   ```bash
   docker-compose logs fleet-server | grep -i error
   ```

---

## Elastic Agent Issues

### Problem: Elastic Agent not enrolling

**Symptoms:**
- Agent not visible in Fleet UI
- Enrollment errors in logs

**Solutions:**

1. Check Fleet Server is healthy:
   ```bash
   curl http://localhost:8220/api/status
   ```

2. Check enrollment token:
   ```bash
   docker-compose logs elastic-agent | grep -i enroll
   ```

3. Generate a new enrollment token in Kibana:
   - Go to Fleet → Agent policies
   - Click on your policy
   - Click "Add agent"
   - Copy the enrollment token
   - Update docker-compose.yml

4. Verify network connectivity:
   ```bash
   docker exec elastic-agent curl -s http://fleet-server:8220/api/status
   ```

5. Re-enroll agent:
   ```bash
   docker-compose stop elastic-agent
   docker-compose rm -f elastic-agent
   docker-compose up -d elastic-agent
   ```

### Problem: Elastic Agent shows "Offline" in Fleet

**Solutions:**

1. Check agent logs:
   ```bash
   docker-compose logs -f elastic-agent
   ```

2. Verify agent can reach Fleet Server:
   ```bash
   docker exec elastic-agent curl -s http://fleet-server:8220/api/status
   ```

3. Check for certificate issues:
   ```bash
   docker-compose logs elastic-agent | grep -i certificate
   ```

### Problem: Elastic Agent not collecting data

**Solutions:**

1. Check if agent is healthy:
   ```bash
   docker exec elastic-agent elastic-agent status
   ```

2. Verify integration is configured:
   - Go to Fleet → Agents
   - Click on your agent
   - Check assigned policies

3. Check data streams:
   ```bash
   curl "http://localhost:9200/_data_stream?pretty"
   ```

4. Check for errors in agent logs:
   ```bash
   docker-compose logs elastic-agent | grep -i error
   ```

---

## Network Issues

### Problem: Services cannot communicate

**Symptoms:**
- Connection refused errors
- DNS resolution failures

**Solutions:**

1. Check Docker network:
   ```bash
   docker network ls
   docker network inspect elastic-integrations-standalone_elastic
   ```

2. Test connectivity between services:
   ```bash
   docker exec kibana ping elasticsearch
   docker exec elastic-agent ping fleet-server
   ```

3. Recreate network:
   ```bash
   docker-compose down
   docker network prune
   docker-compose up -d
   ```

---

## Performance Issues

### Problem: System is slow or unresponsive

**Solutions:**

1. Check resource usage:
   ```bash
   docker stats
   ```

2. Reduce resource consumption:
   
   Edit docker-compose.yml:
   ```yaml
   # Reduce Elasticsearch memory
   environment:
     - "ES_JAVA_OPTS=-Xms256m -Xmx256m"
   ```

3. Limit running services:
   ```bash
   # Start only essential services
   docker-compose up -d elasticsearch kibana
   ```

4. Clean up old data:
   ```bash
   # Delete old indices
   curl -X DELETE "http://localhost:9200/.ds-logs-*-000001"
   ```

---

## Docker Issues

### Problem: "No space left on device"

**Solutions:**

1. Clean up Docker resources:
   ```bash
   docker system prune -a
   docker volume prune
   ```

2. Check disk usage:
   ```bash
   docker system df
   ```

3. Remove old images:
   ```bash
   docker image prune -a
   ```

### Problem: Permission denied errors

**Solutions:**

1. Fix volume permissions:
   ```bash
   sudo chown -R 1000:1000 data/
   ```

2. Run Docker commands with sudo (Linux):
   ```bash
   sudo docker-compose up -d
   ```

3. Add user to docker group (Linux):
   ```bash
   sudo usermod -aG docker $USER
   # Log out and back in
   ```

---

## Getting More Help

### Collect Diagnostic Information

Run these commands and share the output when asking for help:

```bash
# System information
docker version
docker-compose version
uname -a

# Service status
docker-compose ps

# Service logs (last 100 lines)
docker-compose logs --tail=100 elasticsearch
docker-compose logs --tail=100 kibana
docker-compose logs --tail=100 fleet-server
docker-compose logs --tail=100 elastic-agent

# Cluster health
curl http://localhost:9200/_cluster/health?pretty
curl http://localhost:9200/_cat/indices?v

# Resource usage
docker stats --no-stream
df -h
free -h
```

### Useful Commands

```bash
# Completely reset environment
docker-compose down -v
docker-compose up -d

# View logs in real-time
docker-compose logs -f

# Execute command in container
docker exec -it [container-name] bash

# Inspect container
docker inspect [container-name]

# Check container resource limits
docker inspect [container-name] | grep -A 10 Memory
```

### Resources

- [Elastic Community Forums](https://discuss.elastic.co/)
- [Elastic Agent Documentation](https://www.elastic.co/guide/en/fleet/current/elastic-agent-installation.html)
- [Docker Documentation](https://docs.docker.com/)
- [GitHub Issues](https://github.com/clement-fouque/elastic-integrations-standalone/issues)
