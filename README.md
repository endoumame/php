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
