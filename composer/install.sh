#!/usr/bin/env bash
set -euo pipefail

install_dir="${COMPOSER_INSTALL_DIR:-/usr/local/bin}"
filename="${COMPOSER_FILENAME:-composer}"
composer_home="${COMPOSER_HOME:-$HOME/.composer}"

if ! command -v php >/dev/null 2>&1; then
  echo "PHP is not installed or is not available on PATH." >&2
  exit 1
fi

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

installer="$tmp_dir/composer-setup.php"
expected_signature="$tmp_dir/installer.sig"

curl --fail --silent --show-error --location \
  --output "$installer" \
  "https://getcomposer.org/installer"

curl --fail --silent --show-error --location \
  --output "$expected_signature" \
  "https://composer.github.io/installer.sig"

actual_signature="$(php -r "echo hash_file('sha384', '$installer');")"
expected_signature_value="$(cat "$expected_signature")"

if [[ "$actual_signature" != "$expected_signature_value" ]]; then
  echo "Composer installer signature mismatch." >&2
  exit 1
fi

mkdir -p "$install_dir"
mkdir -p "$composer_home" 2>/dev/null || composer_home="$HOME/.composer"

if [[ ! -w "$composer_home" ]]; then
  composer_home="$HOME/.composer"
  mkdir -p "$composer_home"
fi

export COMPOSER_HOME="$composer_home"

if [[ ! -w "$install_dir" ]]; then
  sudo php "$installer" \
    --install-dir="$install_dir" \
    --filename="$filename"
else
  php "$installer" \
    --install-dir="$install_dir" \
    --filename="$filename"
fi

"$install_dir/$filename" --version
