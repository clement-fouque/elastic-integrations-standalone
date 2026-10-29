#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
env_file="$repo_root/.env"

if [[ ! -f "$env_file" ]]; then
  printf 'Missing %s; copy .env.example to .env first.\n' "$env_file" >&2
  exit 1
fi

if [[ $# -eq 0 ]]; then
  printf 'Usage: %s <command> [arguments...]\n' "${BASH_SOURCE[0]}" >&2
  exit 2
fi

set -a
. "$env_file"
set +a

: "${ELASTICSEARCH_ENDPOINTS:?Set ELASTICSEARCH_ENDPOINTS in .env}"
export ES_URL="$ELASTICSEARCH_ENDPOINTS"

cd "$repo_root"
exec "$@"
