# Quick Start Guide

Get up and running with Elastic Agent integration testing in 5 minutes!

## 🚀 Super Quick Start

If you just want to get everything running:

```bash
# 1. Clone the repository
git clone https://github.com/clement-fouque/elastic-integrations-standalone.git
cd elastic-integrations-standalone

# 2. Start everything
./scripts/setup.sh

# 3. Wait for completion (2-3 minutes)
# The script will show you when each service is ready

# 4. Open Kibana
open http://localhost:5601
```

That's it! 🎉

## 📋 What You Get

After running the setup script, you'll have:

- ✅ **Elasticsearch** running on http://localhost:9200
- ✅ **Kibana** running on http://localhost:5601
- ✅ **Fleet Server** running on http://localhost:8220
- ✅ **Elastic Agent** enrolled and collecting data
- ✅ **NGINX Sample App** running on http://localhost:8080

## 🔍 First Steps in Kibana

1. **Open Kibana**: http://localhost:5601

2. **View Fleet Status**:
   - Click on the menu (☰) → Management → Fleet
   - You should see your Elastic Agent connected

3. **Add Integrations**:
   - In Fleet, click "Integrations"
   - Popular integrations to try:
     - System (already collecting data)
     - Docker (monitors your containers)
     - NGINX (monitors the sample app)

4. **View Data**:
   - Click on the menu (☰) → Discover
   - Select data view (e.g., `logs-*`)
   - You'll see logs being collected in real-time!

## 🧪 Testing the Setup

Run the test script to verify everything is working:

```bash
./scripts/test.sh
```

Generate some test traffic:

```bash
# Using the Makefile
make traffic

# Or manually
for i in {1..10}; do curl http://localhost:8080; done
```

## 🛠️ Common Commands

Using the Makefile (recommended):

```bash
make help           # Show all available commands
make status         # Check service status
make logs           # View all logs
make logs-agent     # View Elastic Agent logs only
make health         # Quick health check
make stop           # Stop all services
make start          # Start all services
make clean          # Clean up everything
```

Using Docker Compose directly:

```bash
docker compose ps                    # Check status
docker compose logs -f elastic-agent # Follow agent logs
docker compose restart kibana        # Restart Kibana
docker compose down                  # Stop everything
```

## 📊 Viewing Metrics and Logs

### System Metrics

The Elastic Agent automatically collects system metrics:

1. Go to Kibana → Discover
2. Select data view: `metrics-system.*`
3. You'll see CPU, memory, disk, and network metrics

### Docker Metrics

To enable Docker monitoring:

1. Go to Fleet → Integrations
2. Search for "Docker"
3. Click "Add Docker"
4. Configure and save
5. View metrics in Discover: `metrics-docker.*`

### Application Logs

NGINX logs are being collected:

1. Go to Discover
2. Select data view: `logs-*`
3. Filter by `nginx` in the search bar

## 🔧 Customization

### Change Elasticsearch Memory

Edit `docker-compose.yml`:

```yaml
environment:
  - "ES_JAVA_OPTS=-Xms1g -Xmx1g"  # Increase to 1GB
```

### Add Your Own Application

Add a service to `docker-compose.yml`:

```yaml
  my-app:
    image: my-app:latest
    volumes:
      - ./logs:/var/log/myapp
    networks:
      - elastic
```

Then configure a Custom Logs integration in Fleet to collect the logs.

## 🆘 Troubleshooting

### Services not starting?

Check logs:
```bash
docker compose logs elasticsearch
```

### Not enough memory?

Increase Docker memory:
- Docker Desktop → Settings → Resources → Memory (set to at least 4GB)

### Port conflicts?

Change ports in `docker-compose.yml`:
```yaml
ports:
  - "9201:9200"  # Change 9200 to 9201 on host
```

### More help?

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for detailed solutions.

## 🎯 Next Steps

1. **Explore Integrations**: Browse 300+ integrations in Fleet
2. **Create Dashboards**: Build visualizations in Kibana
3. **Set Up Alerts**: Configure alerting rules
4. **Add More Agents**: Scale to multiple agents
5. **Try APM**: Add application performance monitoring

## 📚 Resources

- [Full README](README.md) - Complete documentation
- [Troubleshooting Guide](TROUBLESHOOTING.md) - Solve common issues
- [Example Configs](examples/) - Sample integration configurations
- [Elastic Docs](https://www.elastic.co/guide/index.html) - Official documentation

## 🛑 Stopping Everything

When you're done:

```bash
# Stop but keep data
docker compose down

# Stop and remove all data
docker compose down -v

# Or use the cleanup script
./scripts/cleanup.sh
```

---

**Need help?** Open an issue on GitHub or check the Elastic Community Forums.

Happy monitoring! 🚀
