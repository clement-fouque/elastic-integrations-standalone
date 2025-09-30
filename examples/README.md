# Example Integration Configurations

This directory contains example configurations for various Elastic Agent integrations.

## Available Examples

### 1. System Integration

Collects system-level metrics and logs:
- CPU usage
- Memory usage
- Disk I/O
- Network statistics
- System logs

### 2. Docker Integration

Monitors Docker containers:
- Container metrics
- Container logs
- Docker events

### 3. NGINX Integration

Monitors NGINX web server:
- Access logs
- Error logs
- Server metrics

### 4. Custom Logs

Example configurations for collecting custom application logs.

## How to Use

1. Start the environment using `docker-compose up -d`
2. Access Kibana at http://localhost:5601
3. Navigate to Fleet → Integrations
4. Search for and install the desired integration
5. Configure the integration with settings from the example files
6. Assign the integration to your Elastic Agent policy

## Configuration Files

- `system-integration.yml` - System metrics and logs configuration
- `docker-integration.yml` - Docker monitoring configuration
- `nginx-integration.yml` - NGINX log parsing configuration
- `custom-logs.yml` - Custom application logs configuration
