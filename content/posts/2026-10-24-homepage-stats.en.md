+++
categories = ["automation", "homelab", "guides"]
date = "2026-10-24T18:12:00.000+02:00"
description = "A lightweight Glances-compatible API for Homepage, built as a small Go service instead of a full monitoring stack."
images = ["images/x6GqP8vL2m.jpg"]
slug = "homepage-stats"
tags = ["docker", "golang", "glances", "homepage", "metrics"]
title = "A Small Glances-Compatible Metrics Server for Homepage"
+++

I wanted the Glances widget in [Homepage](https://gethomepage.dev/) to show a few host metrics without running a full Glances server just for that purpose. I built [homepage-stats](https://github.com/pduchnovsky/homepage-stats) as a small Go service that implements the part of the Glances API the widget needs.

It is intentionally not a full Glances replacement. It serves a focused set of Linux metrics from a static Go binary in a minimal, non-root `scratch` container.

## What it reports

The service implements the Glances endpoints used by the widget:

- CPU usage and load averages
- Memory totals and usage
- Filesystem capacity and usage
- Temperature sensors when the host exposes supported sensor data
- Uptime and basic system information
- A compact `quicklook` response and a health endpoint

Requests can use `/api/4/<endpoint>`, `/api/3/<endpoint>`, or `/<endpoint>`. The v3 path is an alias for this API subset; it does not make the service fully compatible with Glances v3. CPU usage is sampled once per second, while the other metrics are read when requested.

In one homelab deployment, I observed about 10 MB of container memory versus about 100 MB for a minimal Glances setup. That was not a controlled benchmark, and actual usage depends on the host and runtime.

## Compose

The repository's Compose setup publishes the service on localhost by default and keeps the container read-only and unprivileged:

```yaml
services:
  stats:
    image: ${STATS_IMAGE:?Set STATS_IMAGE to a published image}
    user: "${PUID:-65532}:${GUID:-65532}"
    environment:
      - STATS_DISK_PATH=${STATS_DISK_PATH:-/}
      - STATS_PORT=${STATS_PORT:-61208}
    ports:
      - ${STATS_BIND_IP:-127.0.0.1}:${STATS_PORT:-61208}:${STATS_PORT:-61208}
    read_only: true
    cap_drop:
      - ALL
    security_opt:
      - no-new-privileges:true
    restart: unless-stopped
```

Set `STATS_IMAGE` to a release tag or image digest. `STATS_BIND_IP` controls the host interface used for the published port. The default is intentionally local-only; if Homepage runs in another container, put both services on a shared Docker network and use `http://stats:61208`, or bind to a reachable LAN address and firewall access to the Homepage host.

Add the widget to Homepage:

```yaml
- glances:
    url: http://stats:61208
    version: 4
    cpu: true
    mem: true
    cputemp: true
    disk: /
    uptime: true
    label: My Server
```

## Filesystem and sensor access

By default, disk metrics describe the container's `/`, which may be its overlay filesystem rather than a host data volume. To report a specific host filesystem, mount only that path read-only and point `STATS_DISK_PATH` at the mount inside the container:

```yaml
environment:
  - STATS_DISK_PATH=/hostfs
volumes:
  - /path/on/host:/hostfs:ro
```

The API presents the selected filesystem as mountpoint `/`, matching Homepage's `disk: /` selector. Temperature readings depend on host sensor data and supported kernel drivers. The service has no built-in authentication or TLS, so keep it on a trusted network and do not expose it publicly.

CPU, load, and memory come from Linux kernel counters visible to the container; they are not cgroup-specific resource usage. This is useful for a host overview, but it is a different question from “how much CPU is this container using?”

The source is available at [github.com/pduchnovsky/homepage-stats](https://github.com/pduchnovsky/homepage-stats).
