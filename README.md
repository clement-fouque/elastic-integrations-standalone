# Elastic Integrations Standalone

A Docker-based testing environment for Elastic Agent integrations using standalone policies. This project allows you to test Elastic integrations without the need for a full Fleet Server setup. It accelerates testing and validation.

## Overview

This project provides a containerized environment to test Elastic Agent integrations in standalone mode. Each integration has its own Docker Compose file and Elastic Agent policy, plus an [OpenTofu](https://opentofu.org/) root that deploys its Elasticsearch and Kibana assets with the [Elastic provider](https://github.com/elastic/terraform-provider-elasticstack).

| Concern | Owner |
| --- | --- |
| Elasticsearch and Kibana | Your own stack (for example, started with `elastic-package`) |
| Fleet package installation, ingest pipelines, templates, detection rules, connectors | OpenTofu, from JSON files under `integrations/<name>/` |
| Standalone Agent policy and container | Docker Compose |

No Fleet agent policy, enrollment or integration policy is created.

## Prerequisites

| Tool or component | Version |
| --- | --- |
| Elasticsearch/Kibana and standalone Agent | 9.5.5 |
| Elastic provider | 0.16.5 |
| OpenTofu | >= 1.9, < 2 |
| [elastic-package](https://github.com/elastic/elastic-package) | Optional, used by `make stack-restart` |

- Docker with Compose v2 and `make`
- Access to an Elasticsearch cluster and Kibana instance

The Agent uses `host` network mode. It is supported natively on Linux; Docker Desktop requires version 4.34 or later with host networking enabled.

## Project Structure

```
.
├── Makefile                         # Deployment targets
├── .env.example                     # Environment variables template
├── .env                             # Your environment variables (create from .env.example)
├── scripts/
│   └── with-env.sh                  # Loads .env for a single command
├── infrastructure/
│   ├── modules/integration/         # Shared OpenTofu module
│   └── <integration_name>/          # OpenTofu root, one per integration
└── integrations/
    └── <integration_name>/
        ├── compose.yml              # Agent container
        ├── data.compose.yml         # Optional: escli service that loads data before the Agent
        ├── data/data.ndjson         # Optional: documents loaded before the Agent starts
        ├── elastic-agent.yml        # Elastic Agent configuration
        ├── terraform.tfvars         # Fleet package versions
        ├── pipelines/               # Optional: ingest pipelines
        ├── component_templates/     # Optional: component templates
        ├── index_templates/         # Optional: index templates
        ├── ilm/                     # Optional: ILM policies
        ├── data_streams/            # Optional: data streams
        ├── transforms/              # Optional: transforms
        ├── detection_rules/         # Optional: Kibana Security detection rules
        └── connectors/              # Optional: Kibana connectors
```

## Setup

### 1. Environment Configuration

Copy the example environment file and configure your Elasticsearch and Kibana connection:

```bash
cp .env.example .env
chmod 600 .env
```

Edit `.env` to match your stack:

```bash
ELASTICSEARCH_ENDPOINTS=https://localhost:9200
ELASTICSEARCH_USERNAME=elastic
ELASTICSEARCH_PASSWORD=your-password
KIBANA_ENDPOINT=https://localhost:5601
ELASTIC_VERSION=9.5.5
ELASTIC_HOST=https://localhost:9200
```

`ELASTICSEARCH_*` and `KIBANA_ENDPOINT` are used by OpenTofu; `ELASTIC_HOST` is the Elasticsearch URL as seen from the Agent container. `scripts/with-env.sh` loads `.env` for each OpenTofu command, so edits take effect on the next run. `.env` uses shell syntax: quote special characters.

### 2. Integration Installation

You do not need to install the integration in Kibana manually. OpenTofu installs the Fleet package at the version pinned in `integrations/<integration_name>/terraform.tfvars`, together with the integration's assets. Fleet packages are installed stack-wide: integrations that pin different versions of the same package override each other's installed version on deploy.

### 3. Integration-Specific Configuration

Integration settings live in the root `.env`, prefixed with the integration name (for example `GITHUB_ISSUES_`). `.env.example` lists and describes every setting. They are passed only to the Agent container, except `TF_VAR_*` variables, which are passed only to OpenTofu.

## Usage

### Testing an Integration

Start your stack, then choose the integration explicitly (there is no default):

```bash
make deploy-local INTEGRATION=<integration_name>
```

This command will:
1. Initialize, plan and apply only `infrastructure/<integration_name>/` (`tofu-init`, `tofu-plan`, `tofu-apply`)
2. Remove and recreate the integration's Agent container, resetting its cursor (`agent-restart`), with logs in the foreground

Each target can also be run on its own, for example `make tofu-plan INTEGRATION=github_issues`. To restart a local `elastic-package` stack:

```bash
make stack-restart version=9.5.5
```

### Loading Data Before the Agent

An integration can load documents into its data stream before its Agent starts, for example to give detection rules the history they need. The documents live in `integrations/<integration_name>/data/data.ndjson` and are loaded by [escli](https://github.com/Anaethelion/escli-rs) (`ghcr.io/anaethelion/escli:0.2.0-alpha`), using the Elasticsearch username and password from `.env`.

The `data` service in `integrations/<integration_name>/data.compose.yml` runs `escli utils load --pipeline _none /data/data.ndjson` once and exits. The documents are already processed, so the integration's default ingest pipeline is skipped; the Fleet final pipeline still sets `event.ingested` to the load time. The image is published for `linux/amd64` only and runs emulated on arm64 hosts.

To enable it for an integration, copy `integrations/first_epss/data.compose.yml` into the integration folder. In its `compose.yml`, add a `<integration_name>_data` service that extends it and mounts the data directory, then make the Agent wait for it:

```yaml
services:
  <integration_name>:
    # ...
    depends_on:
      <integration_name>_data:
        condition: service_completed_successfully

  <integration_name>_data:
    extends:
      file: ./integrations/<integration_name>/data.compose.yml
      service: data
    volumes:
      - type: bind
        source: ./integrations/<integration_name>/data
        target: /data
        read_only: true
        bind:
          create_host_path: false
```

`make agent-restart` and `make deploy-local` then load the file before every Agent start, after OpenTofu has installed the integration's templates and pipelines. Loading is not deduplicated: run it against a fresh stack, and do not include dates that the Agent will also collect. If any document fails, the service exits with an error and the Agent does not start.

#### Exporting Data With escli

Export documents from a stack that already runs the integration, reusing the data service and its `.env` credentials. Pass an Elasticsearch query clause (not a full search body) on stdin to select a few documents:

```bash
echo '{"terms": {"vulnerability.id": ["CVE-2024-3094", "CVE-2026-110447"]}}' |
  docker compose --project-directory . -f integrations/<integration_name>/compose.yml \
    run --rm --no-deps -T <integration_name>_data \
    utils dump logs-<dataset>-default --query - |
  sed 's/^{"index":{/{"create":{/' > integrations/<integration_name>/data/data.ndjson
```

`escli utils dump` writes bulk `index` actions, but data streams accept only `create`, hence the `sed`. Omit `--query -` to export the whole data stream. Then edit the documents by hand, keeping one action line before each document.

### Available Integrations

Currently available integrations:

- [**github_issues**](integrations/github_issues): GitHub issues for one repository
- [**github_security_advisories**](integrations/github_security_advisories): GitHub global security advisories
- [**cisa_kevs**](integrations/cisa_kevs): CISA Known Exploited Vulnerabilities catalog
- [**first_epss**](integrations/first_epss): FIRST EPSS daily exploit prediction scores

## Configuration

### Elastic Agent Configuration

Each integration includes an `elastic-agent.yml` file with:

- **Outputs**: Elasticsearch connection configuration
- **Inputs**: Integration-specific data collection settings
- **Agent Settings**: Monitoring and download configurations

Settings are read from the container environment set in `integrations/<integration_name>/compose.yml`. Keep any package version set in `compose.yml` aligned with the version in `terraform.tfvars`.

### Integration Assets

Each `infrastructure/<integration_name>/` directory is a complete OpenTofu root with its own local state. It calls the shared module in `infrastructure/modules/integration/`, which discovers every direct `*.json` file in the integration's resource folders (see [Project Structure](#project-structure)). Each file's name is the resource ID. The JSON bodies follow the Elasticsearch and Kibana create APIs; see the [module README](infrastructure/modules/integration/README.md) for the supported fields.

Connector JSON files never contain secrets. The OpenTofu root passes them from an ephemeral `TF_VAR_*` variable through the provider's write-only attribute, so they are not stored in state or plans. Kibana never returns secrets, so after rotating one, change its matching `*_version` variable to resend it.

### Network Configuration

The containers use `host` network mode to simplify connectivity with local Elasticsearch instances. Adjust `network_mode` in `integrations/<integration_name>/compose.yml` and `ELASTIC_HOST` in `.env` if using a different setup.

## Troubleshooting

### Common Issues

1. **Compose configuration errors**: A required variable is missing or empty in `.env`
2. **Connection errors**: Verify Elasticsearch and Kibana connectivity and credentials in `.env`
3. **`Unknown or incomplete integration`**: Check the `INTEGRATION` name matches a directory under both `infrastructure/` and `integrations/`
4. **Template changes not visible**: Template changes apply only to new backing indices; roll over the data stream:
   ```bash
   ./scripts/with-env.sh bash -c 'curl --insecure -u "$ELASTICSEARCH_USERNAME:$ELASTICSEARCH_PASSWORD" -X POST "$ES_URL/<data_stream>/_rollover"'
   ```

### Debugging Steps

1. Check Elastic Agent logs:
   ```bash
   docker compose --project-directory . -f integrations/<integration_name>/compose.yml logs <integration_name>
   ```

2. Verify Elasticsearch connectivity:
   ```bash
   ./scripts/with-env.sh bash -c 'curl --insecure -u "$ELASTICSEARCH_USERNAME:$ELASTICSEARCH_PASSWORD" "$ES_URL/_cluster/health"'
   ```

3. Check that no changes are pending:
   ```bash
   ./scripts/with-env.sh tofu -chdir=infrastructure/<integration_name> plan \
     -var-file=../../integrations/<integration_name>/terraform.tfvars -detailed-exitcode
   ```

### Cleanup

To stop and remove an integration's Agent container:

```bash
docker compose --project-directory . -f integrations/<integration_name>/compose.yml down
```

The Agent cursor lives only in the container filesystem, so the next start collects from scratch. Do not use `tofu destroy` to clean up data: removing templates or pipelines while an Agent runs breaks ingestion.

## Contributing

When adding new integrations:

1. Create a new directory under `integrations/` with `compose.yml`, `elastic-agent.yml` and `terraform.tfvars`
2. Add any asset JSON files in the resource folders supported by the shared module, and optionally a `data/data.ndjson` file (see [Loading Data Before the Agent](#loading-data-before-the-agent))
3. Create an OpenTofu root under `infrastructure/<name>/` that calls `../modules/integration`
4. Add any required environment variables, prefixed with the integration name, to `.env.example`
5. Update this README with the new integration details

## Security Notes

- Never commit real credentials to the repository; `.env`, OpenTofu state and plan files are Git-ignored
- OpenTofu and the Agent's Elasticsearch output skip TLS certificate verification; use only against trusted local development stacks
- Integration credentials are passed only to the Agent; connector secrets are passed only to OpenTofu as ephemeral values
- Consider using API keys instead of username/password for production setups
