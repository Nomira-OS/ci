# ci

Shared CI of the Nomira-OS organisation. The projects call the workflows
here instead of copying them.

## Building blocks

| Workflow | Job |
|---|---|
| `checks.yml` | REUSE licence check and Conventional Commits |
| `go.yml` | gofmt, vet, test, build for a Go module; optionally a Trivy scan that fails on findings |
| `image.yml` | build an image, publish it to ghcr, sign it with cosign, attest provenance, Trivy scan |
| `release.yml` | release from the commits: determine the version, set the tag, GitHub release with changelog |

Plus `default.json`, the shared Renovate preset. A project pulls it in
with `"extends": ["local>Nomira-OS/ci"]`.

## Process

Development happens on `main`. Every push runs `checks` and the tests of
the project. Publishing happens only by hand: start "release" in the
Actions tab of the project and choose the channel.

| Channel | Result |
|---|---|
| `beta` | tag `vX.Y.Z-beta.N`, marked as a pre-release |
| `final` | tag `vX.Y.Z` |

Every release gets a tag and a changelog from the commits; the changelog
is in the GitHub release and in the tag message. With `dry-run` the run
only shows version and changelog.

## Versions

The version follows from the Conventional Commits since the last final
release (git-cliff, configured in `cliff.toml`):

| Commits | before 1.0 | from 1.0 |
|---|---|---|
| `fix:`, `perf:` | patch | patch |
| `feat:` | minor | minor |
| `!` or `BREAKING CHANGE` | minor | major |
| only `docs:`, `chore:`, `ci:` … | no release | no release |

Beta tags do not count as a release: several betas count up `-beta.1`,
`-beta.2`, and the changelog of the final release contains everything
since the last final one. A beta can be published as final without a new
commit. The step to 1.0.0 is taken deliberately by hand.

## Using it

See `examples/ci.yml` and `examples/release.yml`.

## Trying it locally

```sh
pipx install git-cliff==2.14.2
CHANNEL=beta DRY_RUN=true CLIFF_CONFIG=/path/to/ci/cliff.toml sh /path/to/ci/scripts/release.sh
```

## Licence

EUPL-1.2, see `LICENSES/`. Per-file information is in `REUSE.toml`.
