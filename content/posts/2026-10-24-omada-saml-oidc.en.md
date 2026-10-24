+++
categories = ["automation", "homelab", "guides"]
date = "2026-10-24T18:30:00.000+02:00"
description = "Use an OIDC identity provider to sign in to Omada Controller through a small SATOSA-based SAML bridge and ACS proxy."
images = ["images/rT4bN9zK2c.jpg"]
slug = "omada-saml-oidc"
tags = ["omada", "saml", "oidc", "docker", "traefik", "identity"]
title = "OIDC Sign-In for Omada Controller with a SAML Bridge"
+++

I wanted to use an existing OIDC identity provider for Omada Controller sign-in. Omada expects SAML for this flow, so I forked [Omada SAML to OIDC Bridge](https://github.com/pduchnovsky/oc-saml-oidc) and adapted it for homelab deployments, with a focus on reducing its memory footprint. In my homelab, I saw the container's memory use drop from about 260 MB to around 70 MB. That's an observation from my setup, not a universal benchmark.

The bridge uses SATOSA for the OIDC-to-SAML flow and a small reverse proxy for Omada's Assertion Consumer Service (ACS). It can work with providers such as Pocket ID and Authelia.

## The browser flow

1. The user opens the public Omada URL.
2. A reverse-proxy rule sends the root page to the bridge's Omada launch path.
3. SATOSA redirects the browser to the OIDC provider and completes authentication.
4. The bridge returns the SAML response to Omada's ACS URL.
5. The ACS proxy sends the SAML response to the controller's private address, then rewrites matching redirects, cookies, and absolute URLs so the browser continues using the public Omada hostname.

The controller stays on its private address. The browser uses the public Omada URL, while the bridge connects directly to the controller inside the network.

## Compose example

This example runs Omada, its database, and the bridge in one Compose project. The `omada` network is also where a reverse proxy should reach the controller and bridge; the database has a separate internal network and is not published to the host.

```yaml
services:
  oc-db:
    image: mongo:8.0
    volumes:
      - omada-db:/data/db
    networks:
      - database
    healthcheck:
      test: [CMD, mongosh, --quiet, --eval, "db.adminCommand('ping')"]
    restart: unless-stopped

  oc:
    image: mbentley/omada-controller:6.3-openj9
    depends_on:
      oc-db:
        condition: service_healthy
    environment:
      - TZ=Etc/UTC
      - MONGO_EXTERNAL=true
      - EAP_MONGOD_URI=mongodb://oc-db:27017/omada
    volumes:
      - omada-data:/opt/tplink/EAPController/data
      - omada-logs:/opt/tplink/EAPController/logs
    ports:
      - ${OMADA_LAN_IP}:8043:8043/tcp
      - ${OMADA_LAN_IP}:27001:27001/udp
      - ${OMADA_LAN_IP}:29810:29810/udp
      - ${OMADA_LAN_IP}:29811-29817:29811-29817/tcp
    networks:
      - omada
      - database
    restart: unless-stopped

  omada-saml-oidc:
    image: ghcr.io/pduchnovsky/oc-saml-oidc:latest
    env_file:
      - ./omada-saml-oidc.env
    volumes:
      - bridge-data:/data
    networks:
      - omada
    restart: unless-stopped

networks:
  omada: {}
  database:
    internal: true

volumes:
  omada-db:
  omada-data:
  omada-logs:
  bridge-data:
```

The environment file contains the public URLs and the private upstream:

```dotenv
PUBLIC_BASE_URL=https://bridge.example.com
OIDC_PROVIDER_ISSUER=https://auth.example.com
OIDC_CLIENT_ID=omada-saml-oidc
OIDC_CLIENT_SECRET=replace-with-a-secret
OMADA_PUBLIC_BASE_URL=https://omada.example.com
OMADA_UPSTREAM_BASES=https://oc:8043
OMADA_ID=replace-with-omada-id
OMADA_RESOURCE_ID=replace-with-resource-id
OMADA_USERGROUP_TEMPLATE=admin
```

Use the OIDC client secret and Omada SAML identifiers from their respective configuration pages. Keep the environment file out of source control. The bridge creates its SATOSA state-encryption key on first run and persists it under `/data`.

The MongoDB version is intentional: the standard Omada v6 setup uses MongoDB 8, which requires a compatible CPU. An older external MongoDB may be a workaround on unsupported CPUs, but compatibility depends on the exact controller release. MongoDB 4.4 is end-of-life. Check the release requirements and back up before changing database versions.

## Reverse-proxy routing

The public routing needs to distinguish four requests:

- `omada.example.com/` redirects to `bridge.example.com/launch/omada`.
- `bridge.example.com/launch/omada` goes to the bridge.
- `omada.example.com/sso/saml/login` goes to the bridge's ACS handler.
- Other requests for `omada.example.com` go to the Omada controller.

The OIDC provider keeps its own public HTTPS hostname. The repository includes [Traefik](https://github.com/pduchnovsky/oc-saml-oidc/blob/main/examples/traefik-pocket-id.yml) and [nginx](https://github.com/pduchnovsky/oc-saml-oidc/blob/main/examples/nginx-pocket-id.conf) examples; there are separate variants for Authelia.

`OMADA_UPSTREAM_BASES` must use internal addresses reachable from the bridge, such as `https://oc:8043`. Do not put `OMADA_PUBLIC_BASE_URL` there. The proxy rewrites absolute URLs only when they match a configured upstream base, so mismatches can send the browser to an internal hostname after login.

This bridge handles the browser login/ACS flow; it does not replace Omada's device-adoption or management ports. Keep those reachable by the Omada devices as required by your network, and do not expose the database publicly.
