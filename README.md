# Elastic Integrations Standalone

A Docker-based testing environment for Elastic Agent integrations using standalone policies. This project allows you to test Elastic integrations without the need for a full Fleet Server setup. It accelerates testing and validation. 

## Overview

This project provides a containerized environment to test Elastic Agent integrations in standalone mode. Each integration is configured with its own Docker service and Elastic Agent configuration file, making it easy to test and debug integrations independently.

## Prerequisites

- Docker and Docker Compose installed
- Access to an Elasticsearch cluster and Kibana instance
- The target integration must be installed in Kibana before running tests

## Project Structure

```
.
├── compose.yml              # Docker Compose configuration
├── .env.example            # Environment variables template
├── .env                    # Your environment variables (create from .env.example)
└── integrations/
    └── qualys_gav/
        ├── elastic-agent.yml   # Elastic Agent configuration
        └── .env               # Integration-specific environment variables
```

## Setup

### 1. Environment Configuration

Copy the example environment file and configure your Elasticsearch connection:

```bash
cp .env.example .env
```

Edit `.env` to match your Elasticsearch setup:

```bash
ELASTIC_VERSION=9.1.4
ELASTIC_HOST=https://your-elasticsearch-host:9200
ELASTIC_USERNAME=elastic
ELASTIC_PASSWORD=your-password
```

### 2. Integration Installation

**Important:** Before running any integration, you must manually install the integration in Kibana:

1. Open Kibana in your browser
2. Navigate to **Stack Management** → **Integrations**
3. Search for and select your target integration (e.g., "Qualys VMDR")
4. Click on the **Settings** tab
5. Click **Install** to install the integration

This step is required because the Elastic Agent needs the integration's assets (index templates, ingest pipelines, etc.) to be available in Elasticsearch.

### 3. Integration-Specific Configuration

Each integration may have its own environment file with specific configuration:

- Configure integration-specific settings in `integrations/<integration_name>/.env`
- Modify `integrations/<integration_name>/elastic-agent.yml` as needed for your use case

## Usage

### Testing an Integration

To test an integration (using Qualys GAV as an example):

```bash
# Clean up any existing containers and volumes, then start the integration
docker compose down -v && docker compose up <integration_name>
```

This command will:
1. Remove any existing containers and volumes (`down -v`)
2. Start the specified integration service (`up <integration_name>`)

### Available Integrations

Currently available integrations:

- **qualys_gav**: Qualys VMDR (Global Asset View) integration

## Configuration

### Elastic Agent Configuration

Each integration includes an `elastic-agent.yml` file with:

- **Outputs**: Elasticsearch connection configuration
- **Inputs**: Integration-specific data collection settings
- **Agent Settings**: Monitoring and download configurations

### Network Configuration

The containers use `host` network mode to simplify connectivity with local Elasticsearch instances. Adjust the `network_mode` in `compose.yml` if using a different setup.

## Troubleshooting

### Common Issues

1. **Integration not found errors**: Ensure the integration is installed in Kibana before starting the agent
2. **Connection errors**: Verify Elasticsearch connectivity and credentials in `.env`
3. **Permission errors**: Check that the Elastic Agent has appropriate permissions to send data

### Debugging Steps

1. Check Elastic Agent logs:
   ```bash
   docker compose logs qualys_gav
   ```

2. Verify Elasticsearch connectivity:
   ```bash
   curl -u $ELASTIC_USERNAME:$ELASTIC_PASSWORD $ELASTIC_HOST/_cluster/health
   ```

3. Check integration installation in Kibana:
   - Go to Stack Management → Integrations
   - Verify the integration shows as "Installed"

### Cleanup

To completely reset the environment:

```bash
# Stop and remove all containers, networks, and volumes
docker compose down -v

# Remove unused Docker resources
docker system prune -f
```

## Contributing

When adding new integrations:

1. Create a new directory under `integrations/`
2. Add the integration-specific `elastic-agent.yml` configuration
3. Add any required environment variables in a `.env` file
4. Update `compose.yml` with the new service definition
5. Update this README with the new integration details

## Security Notes

- Never commit real credentials to the repository
- Use strong passwords for Elasticsearch authentication
- Consider using API keys instead of username/password for production setups
- Review and adjust SSL verification settings based on your security requirements