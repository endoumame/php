#!/usr/bin/env bash
set -euo pipefail

min_version="${MIN_VERSION:-0.0.0}"
max_count="${MAX_COUNT:-10}"

if [[ ! "$min_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "MIN_VERSION must be in x.y.z format: $min_version" >&2
  exit 1
fi

if [[ ! "$max_count" =~ ^[0-9]+$ ]] || (( max_count < 1 || max_count > 250 )); then
  echo "MAX_COUNT must be between 1 and 250: $max_count" >&2
  exit 1
fi

tmp_versions="$(mktemp)"
trap 'rm -f "$tmp_versions"' EXIT

curl --fail --silent --show-error --location \
  "https://dl.static-php.dev/static-php-cli/bulk/?format=json" |
  jq -r '
    .[]
    | select(.is_dir == false)
    | .name
    | capture("^php-(?<version>[0-9]+\\.[0-9]+\\.[0-9]+)-cli-.+\\.tar\\.gz$")
    | .version
  ' |
  sort -uV |
  while IFS= read -r version; do
    if [[ "$(printf '%s\n%s\n' "$min_version" "$version" | sort -V | head -n1)" == "$min_version" ]]; then
      printf '%s\n' "$version"
    fi
  done |
  tail -n "$max_count" > "$tmp_versions"

jq -R -s -c 'split("\n") | map(select(length > 0))' "$tmp_versions"
