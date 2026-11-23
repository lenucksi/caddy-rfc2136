# caddy-rfc2136

Signiertes Caddy-Image fuer die Heinzbox: offizielles `caddy:<version>-alpine`
plus die Module

- `github.com/caddy-dns/rfc2136` (`dns.providers.rfc2136`) — LE DNS-01 gegen unseren Knot
- `github.com/mholt/caddy-events-exec` (`events.handlers.exec`) — Renewal-Hook

## Tags

- `:2.11.9` — exakte Version (Pins aus dem `Dockerfile`)
- `:2` — Major-Alias, den die Hosts ziehen (Auto-Update wie beim offiziellen `caddy:2`)

## Update-Policy

- **Renovate** bumped die Pins (`CADDY_VERSION`, Modul-Commits, Actions) per PR.
  PRs mit gruenen Required Checks werden per GitHub Auto-Merge automatisch gemerged.
- **Taeglich** prueft der Workflow (04:17 UTC), ob sich der Digest des
  upstream Base-Images geaendert hat. Nur dann wird neu gebaut und gepusht —
  dadurch landen OS-/Go-CVE-Fixes automatisch im Image.
- **Major-Updates** (Caddy 3.x) bleiben manuell.

## Signatur

Der Workflow signiert nach dem Push **by digest** mit einem key-basierten
cosign-Key (GitHub Secret `COSIGN_PRIVATE_KEY` / `COSIGN_PASSWORD`), im
Legacy-`.sig`-Format (cosign **v3.1.3**), damit die
`containers/image`-Policy der Hosts es beim Pull aus GHCR verifizieren kann.
Der zugehoerige Public Key liegt in [`cosign.pub`](cosign.pub).

Zusaetzlich wird eine SLSA-Provenance-Attestation erzeugt (`actions/attest`) —
als oeffentliche Nachweisbarkeit, nicht als Ersatz fuer die Pull-Time-Signatur.

## Host-Konfiguration

`/etc/containers/policy.json`:

```json
"ghcr.io/lenucksi/caddy-rfc2136": [
  { "type": "sigstoreSigned",
    "keyPath": "/etc/pki/containers/caddy-rfc2136.pub",
    "signedIdentity": { "type": "matchRepository" } }
]
```

`/etc/containers/registries.d/ghcr.yaml`:

```yaml
docker:
  ghcr.io/lenucksi/caddy-rfc2136:
    use-sigstore-attachments: true
```
