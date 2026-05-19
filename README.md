# PHP Releases

Personal PHP release repository inspired by `verzly/php`.

This repository publishes static PHP CLI builds as GitHub Releases for Linux,
macOS, and Windows. It is intentionally manual-only: releases are created when
you run GitHub Actions, not on a daily schedule.

## Workflows

- `PHP Release`: manually release one PHP version, for example `8.4.3`.
- `PHP Bulk Release`: manually find and release versions greater than or equal
  to `minimum_version`, capped by `max_count`.
- `Revert PHP Releases`: manually delete release tags in a version range.

## Security posture

The workflows are designed for recent GitHub Actions supply-chain incidents:

- no cron trigger
- no third-party dispatch or release Actions
- `actions/checkout` pinned to a full-length commit SHA
- fixed `ubuntu-24.04` runner label instead of `ubuntu-latest`
- least-privilege `GITHUB_TOKEN` permissions
- validated manual inputs
- SHA-256 checksums published with release assets

See [SECURITY.md](SECURITY.md) for operating notes.

## Install with mise

This repository includes an asdf-compatible plugin, so you can add it directly:

```bash
mise plugin add php https://github.com/endoumame/php
mise use php@8.2.30
php --version
```

If you prefer the GitHub backend, this alias-based setup also works:

```bash
mise plugin rm php
mise config set tool_alias.php github:endoumame/php
mise use php@8.2.30
php --version
```

Use the latest available release:

```bash
mise use php@latest
```

Without an alias, use the full backend reference:

```bash
mise use github:endoumame/php@8.2.30
```

## Install Composer

Composer can be installed after PHP is available on `PATH`.

Linux and macOS:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/endoumame/php/main/composer/install.sh)
composer --version
```

Windows PowerShell:

```powershell
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/endoumame/php/main/composer/install.ps1'))
composer --version
```

The installer script verifies the official Composer installer SHA-384 signature
before running it.

## Release manually

Open the repository's Actions tab, choose `PHP Release`, and enter a version:

```text
8.4.3
```

For a range, choose `PHP Bulk Release` and set:

```text
minimum_version: 8.4.0
max_count: 10
```

## Release assets

Each release contains matching static PHP CLI archives discovered from:

- https://dl.static-php.dev/static-php-cli/bulk/
- https://dl.static-php.dev/static-php-cli/windows/spc-max/

Each release also includes `SHA256SUMS`.
