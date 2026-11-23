# syntax=docker/dockerfile:1
# Reproduzierbarer Caddy-Build mit den zwei Modulen, die wir fuer die
# Heinzbox-SIP-TLS brauchen:
#   dns.providers.rfc2136  -> LE DNS-01 gegen unseren Knot (TSIG)
#   events.handlers.exec   -> Renewal-Hook fuer die FS-Zertifikatsdateien
#
# Alle Versionen sind PINS (kein floating main). Renovate bumped sie per PR,
# der nach gruenen Checks automatisch gemerged wird.
ARG CADDY_VERSION=2.11.9
ARG RFC2136_VERSION=e50b9f25dd68882c76758446195aca0507be3c05
ARG EVENTSEXEC_VERSION=3a351bf9c023b8f9305aaceaa5bf004b31a0ca3d
# CVE-2026-78661 (golang.org/x/net/html DoS): Caddy 2.11.9 zieht v0.60.0,
# fix ist v0.62.0. `--replace` setzt die Version im Build-go.mod hoch, ohne
# Caddy selbst zu patchen. Renovate bumped diesen Pin, sobald upstream fixiert.
ARG XNET_VERSION=v0.62.0
ARG BASE_DIGEST=unknown

FROM caddy:${CADDY_VERSION}-builder AS builder
ARG RFC2136_VERSION
ARG EVENTSEXEC_VERSION
ARG XNET_VERSION
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    xcaddy build \
      --with github.com/caddy-dns/rfc2136@${RFC2136_VERSION} \
      --with github.com/mholt/caddy-events-exec@${EVENTSEXEC_VERSION} \
      --replace golang.org/x/net=golang.org/x/net@${XNET_VERSION}

FROM caddy:${CADDY_VERSION}-alpine
ARG CADDY_VERSION
ARG RFC2136_VERSION
ARG EVENTSEXEC_VERSION
ARG XNET_VERSION
ARG BASE_DIGEST
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
LABEL org.opencontainers.image.source="https://github.com/lenucksi/caddy-rfc2136" \
      org.opencontainers.image.description="Signed Caddy with RFC2136 DNS-01 for Heinzbox SIP-TLS" \
      org.opencontainers.image.version="${CADDY_VERSION}" \
      org.opencontainers.image.base.digest="${BASE_DIGEST}" \
      org.opencontainers.image.rfc2136.version="${RFC2136_VERSION}" \
      org.opencontainers.image.events-exec.version="${EVENTSEXEC_VERSION}"
