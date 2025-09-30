# Elastic Integrations Standalone

A Docker-based testing environment for Elastic Agent integrations. This repository provides a complete setup to test and validate Elastic Agent with various integrations using Docker containers.

## Overview

This repository contains a Docker Compose setup that includes:
- **Elasticsearch** - The search and analytics engine
- **Kibana** - Visualization and management interface
- **Fleet Server** - Centralized management for Elastic Agents
- **Elastic Agent** - Agent for collecting and shipping data
- **Sample Application** - NGINX server for generating test logs

## Prerequisites

- Docker (version 20.10 or higher)
- Docker Compose (version 2.0 or higher)
- At least 4GB of available RAM
- curl (for testing scripts)

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/clement-fouque/elastic-integrations-standalone.git
cd elastic-integrations-standalone
```

### 2. Start the Environment

Use the automated setup script:

```bash
./scripts/setup.sh
```

Or manually start services:

```bash
docker-compose up -d
```

### 3. Access the Services

Once all services are running, you can access:

- **Elasticsearch**: http://localhost:9200
- **Kibana**: http://localhost:5601
- **Fleet Server**: http://localhost:8220
- **Sample NGINX**: http://localhost:8080

### 4. Verify the Setup

Run the test script to verify all services are working:

```bash
./scripts/test.sh
```

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Docker Network                        │
│                                                          │
│  ┌──────────────┐      ┌──────────────┐                │
│  │ Elasticsearch├──────┤    Kibana    │                │
│  └──────┬───────┘      └──────┬───────┘                │
│         │                     │                         │
│         │              ┌──────┴───────┐                 │
│         │              │ Fleet Server │                 │
│         │              └──────┬───────┘                 │
│         │                     │                         │
│         │              ┌──────┴───────┐                 │
│         └──────────────┤Elastic Agent │                │
│                        └──────┬───────┘                 │
│                               │                         │
│                        ┌──────┴───────┐                 │
│                        │    NGINX     │                 │
│                        │   (Sample)   │                 │
│                        └──────────────┘                 │
└─────────────────────────────────────────────────────────┘
```

## Configuration

### Environment Variables

The `.env` file contains configuration for the Elastic Stack:

- `ELASTIC_VERSION`: Version of Elastic Stack components
- `ELASTICSEARCH_HOST`: Elasticsearch endpoint
- `KIBANA_HOST`: Kibana endpoint
- `FLEET_URL`: Fleet Server endpoint

### Docker Compose Services

#### Elasticsearch
- Port: 9200
- Single-node cluster for testing
- Security disabled for easier testing
- Persistent data volume

#### Kibana
- Port: 5601
- Connected to Elasticsearch
- Fleet management enabled
- Includes encryption key for saved objects

#### Fleet Server
- Port: 8220
- Manages Elastic Agents
- Automatic setup with Kibana
- Insecure HTTP mode for testing

#### Elastic Agent
- Automatically enrolled with Fleet Server
- Monitors Docker containers
- Collects system metrics and logs
- Runs with root privileges to access system resources

#### NGINX Sample
- Port: 8080
- Generates access and error logs
- Health check endpoint at `/health`

## Usage

### Starting the Environment

```bash
# Start all services
docker-compose up -d

# Start specific service
docker-compose up -d elasticsearch
```

### Viewing Logs

```bash
# View all logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f elastic-agent
docker-compose logs -f elasticsearch
```

### Checking Service Status

```bash
# Check all containers
docker-compose ps

# Check Elasticsearch health
curl http://localhost:9200/_cluster/health?pretty

# Check Kibana status
curl http://localhost:5601/api/status

# Check Fleet Server status
curl http://localhost:8220/api/status
```

### Generating Test Data

Generate some traffic to NGINX to create logs:

```bash
# Generate access logs
for i in {1..10}; do curl http://localhost:8080; done

# Generate health check logs
for i in {1..5}; do curl http://localhost:8080/health; done
```

### Adding Integrations in Kibana

1. Open Kibana at http://localhost:5601
2. Navigate to **Management** → **Fleet**
3. Click on **Agents** to see your enrolled agent
4. Go to **Integration** to add new integrations:
   - System Integration (for system metrics)
   - Docker Integration (for container metrics)
   - Custom Log Integration (for application logs)

### Viewing Data in Kibana

1. Open Kibana at http://localhost:5601
2. Navigate to **Discover** to view ingested logs
3. Create visualizations in **Visualize Library**
4. Build dashboards in **Dashboard**

## Testing Integrations

### System Integration

The Elastic Agent automatically collects system metrics:

```bash
# View system metrics in Elasticsearch
curl "http://localhost:9200/metrics-system*/_search?pretty&size=5"
```

### Docker Integration

Monitor Docker containers:

```bash
# View Docker metrics in Elasticsearch
curl "http://localhost:9200/metrics-docker*/_search?pretty&size=5"
```

### Custom Logs

Add custom log files to be monitored:

1. Mount your log directory as a volume in the Elastic Agent service
2. Configure a Custom Logs integration in Fleet
3. Specify the log file path

## Troubleshooting

### Service Not Starting

Check logs for the specific service:

```bash
docker-compose logs [service-name]
```

### Elasticsearch Not Healthy

Ensure you have enough memory:

```bash
# Check container resources
docker stats

# Increase memory if needed (edit docker-compose.yml)
# ES_JAVA_OPTS: -Xms512m -Xmx1g
```

### Elastic Agent Not Enrolling

Check Fleet Server token and URL:

```bash
# View Elastic Agent logs
docker-compose logs elastic-agent

# Ensure Fleet Server is running
docker-compose ps fleet-server
```

### Port Conflicts

If ports are already in use, modify the port mappings in `docker-compose.yml`:

```yaml
ports:
  - "9201:9200"  # Change host port (left side)
```

## Cleanup

### Stop Services

```bash
# Stop all services but keep data
docker-compose down

# Stop and remove all data
docker-compose down -v
```

### Automated Cleanup

Use the cleanup script:

```bash
./scripts/cleanup.sh
```

## Scripts

### setup.sh
Automated setup script that starts all services in the correct order and waits for each to be ready.

### test.sh
Verification script that tests all services and checks their health status.

### cleanup.sh
Cleanup script that stops all services and optionally removes data volumes.

## Advanced Configuration

### Custom Elasticsearch Settings

Edit the `docker-compose.yml` file to add custom Elasticsearch settings:

```yaml
environment:
  - cluster.routing.allocation.disk.threshold_enabled=false
  - indices.query.bool.max_clause_count=2048
```

### Custom Kibana Plugins

Add custom Kibana plugins by mounting them:

```yaml
volumes:
  - ./kibana-plugins:/usr/share/kibana/plugins
```

### Multiple Elastic Agents

Scale Elastic Agents:

```bash
docker-compose up -d --scale elastic-agent=3
```

## Security Considerations

⚠️ **Warning**: This setup is designed for **testing and development only**. It disables security features for ease of use.

For production environments:
- Enable Elasticsearch security (xpack.security.enabled=true)
- Use TLS/SSL for all communications
- Set strong passwords for all services
- Implement proper authentication and authorization
- Use secure enrollment tokens
- Regularly update to latest versions

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is open source and available under the MIT License.

## Resources

- [Elastic Agent Documentation](https://www.elastic.co/guide/en/fleet/current/elastic-agent-installation.html)
- [Fleet and Elastic Agent Guide](https://www.elastic.co/guide/en/fleet/current/index.html)
- [Elastic Integrations](https://www.elastic.co/integrations)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

## Support

For issues and questions:
- Open an issue in this repository
- Check the [Elastic Community Forums](https://discuss.elastic.co/)
- Review [Elastic Documentation](https://www.elastic.co/guide/index.html)