# Security Notes

This repository intentionally keeps GitHub Actions small and auditable.

## GitHub Actions hardening

- Workflows are manual only through `workflow_dispatch`; there is no scheduled cron trigger.
- Jobs use `ubuntu-24.04` instead of a moving `ubuntu-latest` runner label.
  GitHub-hosted `runs-on` labels cannot be pinned by image digest in workflow
  syntax, so strict runner-image immutability requires a controlled
  self-hosted runner or a digest-pinned job container.
- Third-party Actions are avoided except for `actions/checkout`, which is pinned to the full commit SHA `de0fac2e4500dabe0009e67214ff5f5447ce83dd`.
- `GITHUB_TOKEN` defaults to `contents: read`; release jobs elevate only the job that needs `contents: write`.
- User-provided workflow inputs are validated as semantic versions before they are used in shell scripts.
- Release assets include a `SHA256SUMS` file.

## Operating guidance

- Review workflow diffs before running release workflows.
- Rotate secrets immediately if a workflow log ever exposes sensitive data.
- Prefer adding repository or organization policy that requires Actions to be pinned to full-length commit SHAs.
- Re-audit pinned Action SHAs before updating them.
