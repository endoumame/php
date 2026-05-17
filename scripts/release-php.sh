#!/usr/bin/env bash
set -euo pipefail

version="${VERSION:?VERSION is required}"

if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "VERSION must be in x.y.z format: $version" >&2
  exit 1
fi

tag="v${version}"
download_dir="${DOWNLOAD_DIR:-downloads}"

if [[ -z "$download_dir" || "$download_dir" == "/" ]]; then
  echo "DOWNLOAD_DIR is unsafe: $download_dir" >&2
  exit 1
fi

rm -rf "$download_dir"
mkdir -p "$download_dir"

matching_paths="$(mktemp)"
trap 'rm -f "$matching_paths"' EXIT

for endpoint in \
  "https://dl.static-php.dev/static-php-cli/bulk/?format=json" \
  "https://dl.static-php.dev/static-php-cli/windows/spc-max/?format=json"
do
  curl --fail --silent --show-error --location "$endpoint" |
    jq -r '.[] | select(.is_dir == false) | .full_path' >> "$matching_paths"
done

version_pattern="${version//./\\.}"
while IFS= read -r filepath; do
  filename="$(basename "$filepath")"

  if [[ "$filename" =~ ^php-${version_pattern}-cli-(.+)\.tar\.gz$ ]]; then
    arch="${BASH_REMATCH[1]}"
    extension="tar.gz"
  elif [[ "$filename" =~ ^php-${version_pattern}-cli-(.+)\.zip$ ]]; then
    arch="${BASH_REMATCH[1]}"
    extension="zip"
  else
    continue
  fi

  output="${download_dir}/php-${version}-cli-${arch}.${extension}"
  echo "Downloading ${filename} -> $(basename "$output")"
  curl --fail --show-error --location --output "$output" "https://dl.static-php.dev/${filepath}"
done < "$matching_paths"

asset_count="$(find "$download_dir" -type f \( -name '*.tar.gz' -o -name '*.zip' \) | wc -l | tr -d ' ')"
if [[ "$asset_count" == "0" ]]; then
  echo "No static PHP CLI assets found for PHP $version" >&2
  exit 1
fi

(
  cd "$download_dir"
  sha256sum * > SHA256SUMS
)

major="${version%%.*}"
body_file="$(mktemp)"
trap 'rm -f "$matching_paths" "$body_file"' EXIT
cat > "$body_file" <<EOF
# PHP ${tag}

Changelog: https://www.php.net/ChangeLog-${major}.php#${version}

## Sources
* Official PHP: https://php.net/releases
* Static PHP CLI: https://dl.static-php.dev/static-php-cli/
* Windows static builds: https://dl.static-php.dev/static-php-cli/windows/spc-max/

## Integrity
Download SHA-256 checksums from the \`SHA256SUMS\` release asset.
EOF

if gh release view "$tag" >/dev/null 2>&1; then
  echo "Release $tag already exists. Refusing to overwrite it." >&2
  exit 1
fi

gh release create "$tag" "$download_dir"/* \
  --target "${GITHUB_SHA:?GITHUB_SHA is required}" \
  --title "$tag" \
  --notes-file "$body_file"
