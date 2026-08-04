# aMule for Umbrel

This repository packages [aMule 3.0.1](https://github.com/amule-org/amule/releases/tag/3.0.1)
as a headless, multi-architecture container and an umbrelOS app. The image uses
Debian 13 slim and installs the official checksum-verified amd64 or arm64
AppImage. It runs `amuled` with the bundled native `amuleweb` interface.

## Test locally

Docker and Docker Compose are required:

```sh
mkdir -p local-data/config local-data/downloads
AMULE_WEB_PASSWORD=choose-a-password docker compose up --build
```

Open <http://localhost:4711> and enter the chosen password. Persistent test data
is written under `local-data/`. Stop it with `docker compose down`.

## Publish the image

The workflow in `.github/workflows/docker.yml` publishes a public multi-arch
image to `ghcr.io/davidegx/amule-umbrel:3.0.1` when a `v*` tag is pushed, or
when run manually. The Umbrel package is configured to use this image. Before
installing it:

1. Publish the image and make the GHCR package public.
2. Inspect the multi-arch index with
   `docker buildx imagetools inspect ghcr.io/davidegx/amule-umbrel:3.0.1`.
3. For an official Umbrel App Store submission, append the index digest to the
   image reference as `:3.0.1@sha256:<digest>`.

## Umbrel data and networking

- Configuration: `${APP_DATA_DIR}/data/config`
- Completed files: Umbrel `Downloads/amule/complete`
- Partial files: Umbrel `Downloads/amule/incomplete`
- WebUI: internal TCP 4711, exposed through Umbrel's authenticated app proxy
- eD2k TCP: host port 4662
- Kad/eD2k UDP: host port 4672

The WebUI password is Umbrel's deterministic per-install `APP_PASSWORD`, shown
in the app details. aMule stores only its MD5-format compatibility hash in
`amule.conf`. Changing the password inside aMule is preserved across restarts.

## License

aMule is distributed under GPL-2.0-or-later. Its source and corresponding
release artifacts are available from the
[upstream 3.0.1 release](https://github.com/amule-org/amule/releases/tag/3.0.1).
