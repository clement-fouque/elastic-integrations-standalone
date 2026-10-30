# FIRST EPSS Test Data

`data.ndjson` is loaded into `logs-first_epss.vulnerability-default` before the FIRST EPSS Agent starts (see [Loading Data Before the Agent](../../../README.md#loading-data-before-the-agent)). It holds 13 snapshots of 10 real CVEs, exported from the 2026-10-30 EPSS snapshot and edited to trigger both FIRST EPSS detection rules:

| CVE | Snapshots in the file | Purpose |
| --- | --- | --- |
| CVE-2021-44228 | 2026-10-25: 0.99999 | Silent baseline above 0.99 for the *Score Above 99%* rule |
| CVE-2024-3094 | 2026-10-27: 0.909, 2026-10-29: 0.992 | Goes above 0.99: alerts in *Score Above 99%* |
| CVE-2026-110447 | 2026-10-27: 0.11634, 2026-10-29: 0.52 | Rises by 0.40: alerts in *Score Rise Above 0.2 in 3 Days* |
| CVE-2023-31719 | 2026-10-27: 0.26032, 2026-10-29: 0.35 | Rises by 0.09: no alert |
| CVE-2016-5195, CVE-2023-23397, CVE-2024-1086, CVE-2024-21762, CVE-2025-58434, CVE-2026-111497 | 2026-10-29 | Unchanged scores below 0.99: no alert |

## Editing the Scenarios

Change `first_epss.vulnerability.date`, `first_epss.vulnerability.epss` and `first_epss.vulnerability.percentile`. Keep `vulnerability.id` and `first_epss.vulnerability.cve` consistent.

Both rules only look at the last 3 days, so move the dates forward before each test:

- Keep the CVE-2021-44228 baseline more than 3 days old.
- Keep the other dates within the last 3 days.
- Keep all dates before the snapshot the Agent collects, so the Agent does not index the same dates again.

The baseline document makes every real CVE above 0.99 in the snapshot the Agent collects look newly scored, so the *Score Above 99%* rule also alerts on those (about 280 CVEs, at most 100 per run). To test only this file, load it without starting the Agent:

```bash
./scripts/with-env.sh docker compose --project-directory . -f integrations/first_epss/compose.yml up first_epss_data
```

## Exporting CVEs

Export more CVEs from a stack that already runs the integration:

```bash
echo '{"terms": {"vulnerability.id": ["CVE-2024-3094", "CVE-2026-110447"]}}' |
  ./scripts/with-env.sh docker compose --project-directory . -f integrations/first_epss/compose.yml \
    run --rm --no-deps -T first_epss_data \
    utils dump logs-first_epss.vulnerability-default --query - |
  sed 's/^{"index":{/{"create":{/' > /tmp/epss.ndjson
```

Then copy the lines you need into `data.ndjson` and edit them.
