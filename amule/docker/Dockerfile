# syntax=docker/dockerfile:1.7

ARG DEBIAN_VERSION=13-slim@sha256:020c0d20b9880058cbe785a9db107156c3c75c2ac944a6aa7ab59f2add76a7bd

FROM debian:${DEBIAN_VERSION} AS extractor

ARG TARGETARCH
ARG AMULE_VERSION=3.0.1
ARG AMULE_SHA256_AMD64=fc74df9f66a924a067fa0f0c946561a70e261e4a74bd476cc97a2f6b758b59cf
ARG AMULE_SHA256_ARM64=bc08d102131f77bee5f1c9183959a01773cadb1cef4d9bd18285b8b15dbe0fcb
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install --yes --no-install-recommends ca-certificates curl squashfs-tools \
    && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    case "${TARGETARCH}" in \
        amd64) artifact_arch="x64"; expected_sha256="${AMULE_SHA256_AMD64}" ;; \
        arm64) artifact_arch="arm64"; expected_sha256="${AMULE_SHA256_ARM64}" ;; \
        *) echo "Unsupported target architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    artifact="aMule-${AMULE_VERSION}-Linux-${artifact_arch}.AppImage"; \
    curl --fail --location --retry 3 \
        "https://github.com/amule-org/amule/releases/download/${AMULE_VERSION}/${artifact}" \
        --output /tmp/amule.AppImage; \
    echo "${expected_sha256}  /tmp/amule.AppImage" | sha256sum --check --strict; \
    offset=""; \
    for candidate in $(LC_ALL=C grep -aob 'hsqs' /tmp/amule.AppImage | cut -d: -f1); do \
        if unsquashfs -s -o "${candidate}" /tmp/amule.AppImage >/dev/null 2>&1; then \
            offset="${candidate}"; \
            break; \
        fi; \
    done; \
    test -n "${offset}"; \
    unsquashfs -no-progress -o "${offset}" -d /opt/amule /tmp/amule.AppImage; \
    test -x /opt/amule/usr/bin/amuled; \
    test -x /opt/amule/usr/bin/amuleweb

FROM debian:${DEBIAN_VERSION}

ARG AMULE_VERSION=3.0.1
ARG DEBIAN_FRONTEND=noninteractive

LABEL org.opencontainers.image.title="aMule for Umbrel" \
      org.opencontainers.image.description="aMule daemon and WebUI packaged for umbrelOS" \
      org.opencontainers.image.version="${AMULE_VERSION}" \
      org.opencontainers.image.source="https://github.com/davidegx/amule-umbrel" \
      org.opencontainers.image.licenses="GPL-2.0-or-later"

RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
        ca-certificates \
        curl \
        libgmp10 \
        libreadline8t64 \
        libstdc++6 \
        zlib1g \
    && rm -rf /var/lib/apt/lists/*

COPY --from=extractor /opt/amule /opt/amule
COPY entrypoint.sh /usr/local/bin/amule-entrypoint

RUN chmod 0755 /usr/local/bin/amule-entrypoint

ENV APPDIR=/opt/amule \
    GSETTINGS_SCHEMA_DIR=/opt/amule/usr/share/glib-2.0/schemas \
    HOME=/config \
    PATH=/opt/amule/usr/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    XDG_DATA_DIRS=/opt/amule/usr/share:/usr/local/share:/usr/share

USER 1000:1000
WORKDIR /config

EXPOSE 4711/tcp 4662/tcp 4672/udp

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=5 \
    CMD curl --fail --silent --output /dev/null http://127.0.0.1:4711/ || exit 1

ENTRYPOINT ["/usr/local/bin/amule-entrypoint"]
