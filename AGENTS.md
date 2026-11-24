# AGENTS.md

Guidance for coding agents (and humans) working in this repository.

## What this is

The shared CI of the Nomira-OS organization: reusable GitHub workflows,
the release script and the Renovate preset. The project repositories
(`nomira`, `nomira-cli`, `arch-base`, `nomira-web`) call these instead
of copying them.

## Layout

- `.github/workflows/checks.yml`, `go.yml`, `image.yml`, `release.yml`:
  reusable workflows (`workflow_call`).
- `.github/workflows/ci.yml`: this repository's own checks.
- `scripts/release.sh`: version, tag and changelog from Conventional Commits.
- `scripts/commit-lint.sh`: Conventional Commits check.
- `cliff.toml`: git-cliff configuration (changelog layout, bump rules).
- `default.json`: Renovate preset, used as `local>Nomira-OS/ci`.
- `examples/`: how a project calls the workflows.

## Rules

- **A change here affects every project.** Callers reference `@main`, so
  a broken workflow breaks all repositories at once. Test scripts locally
  (see README) and say what you could not run.
- **Conventional Commits** for every commit; releases are cut by hand
  from the Actions tab, never by pushing a tag.
- **Versions are pinned.** Never `latest`; actions by commit SHA with the
  version as a trailing comment; runners by version.
- **Scripts are POSIX sh** and must pass `shellcheck`.
- **Licence:** EUPL-1.2, declared through `REUSE.toml`; `reuse lint` must pass.
- **Language:** everything is English: README, docs, code, comments and
  commit messages.
