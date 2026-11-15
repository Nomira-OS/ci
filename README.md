# ci

Gemeinsame CI der Organisation Nomira-OS. Die Projekte rufen die
Workflows hier auf, statt sie zu kopieren.


## Bausteine

| Workflow | Aufgabe |
|---|---|
| `checks.yml` | REUSE-Lizenzprüfung und Conventional Commits |
| `go.yml` | gofmt, vet, test, build für ein Go-Modul; auf Wunsch ein Trivy-Scan, der bei Funden abbricht |
| `image.yml` | Image bauen, nach ghcr veröffentlichen, mit cosign signieren, Herkunftsnachweis, Trivy-Scan |
| `release.yml` | Release aus den Commits: Version bestimmen, Tag setzen, GitHub-Release mit Changelog |

Dazu `default.json`, die gemeinsame Renovate-Vorlage. Ein Projekt bindet
sie mit `"extends": ["github>Nomira-OS/ci"]` ein.

## Ablauf

Entwickelt wird auf `main`. Bei jedem Push laufen `checks` und die Tests
des Projekts. Veröffentlicht wird nur von Hand: Im Actions-Tab des
Projekts „release“ starten und den Kanal wählen.

| Kanal | Ergebnis |
|---|---|
| `beta` | Tag `vX.Y.Z-beta.N`, als Vorabversion markiert |
| `final` | Tag `vX.Y.Z` |

Jedes Release bekommt einen Tag und ein Changelog aus den Commits; das
Changelog steht im GitHub-Release und in der Tag-Nachricht. Mit
`dry-run` zeigt der Lauf nur Version und Changelog.

## Versionen

Die Version folgt aus den Conventional Commits seit dem letzten finalen
Release (git-cliff, Konfiguration in `cliff.toml`):

| Commits | vor 1.0 | ab 1.0 |
|---|---|---|
| `fix:`, `perf:` | Patch | Patch |
| `feat:` | Minor | Minor |
| `!` oder `BREAKING CHANGE` | Minor | Major |
| nur `docs:`, `chore:`, `ci:` … | kein Release | kein Release |

Beta-Tags zählen nicht als Release: Mehrere Betas zählen `-beta.1`,
`-beta.2` hoch, und das finale Release enthält im Changelog alles seit
dem letzten finalen. Ein Beta-Stand lässt sich ohne neuen Commit final
veröffentlichen. Der Schritt auf 1.0.0 geschieht bewusst von Hand.

## Einbinden

Siehe `examples/ci.yml` und `examples/release.yml`.

## Lokal ausprobieren

```sh
pipx install git-cliff==2.14.2
CHANNEL=beta DRY_RUN=true CLIFF_CONFIG=/pfad/zu/ci/cliff.toml sh /pfad/zu/ci/scripts/release.sh
```

## Lizenz

EUPL-1.2, siehe `LICENSES/`. Die Angaben je Datei stehen in `REUSE.toml`.
