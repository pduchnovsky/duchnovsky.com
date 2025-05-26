+++
categories = ["automation", "guides", "scripts"]
date = 2025-05-20T23:45:00
description = "Dual Traefik instance setup with automatic fallback and Authelia authentication on both nodes"
externalLink = ""
images = ["images/8sdasf6fsag8.jpg"]
series = []
slug = "traefik-dual-authelia"
tags = ["traefik", "docker", "authelia", "authentication"]
title = "Traefik with Fallback Routing and Authelia Authentication on Dual Servers"
+++

Running a resilient, secure service infrastructure across two nodes can be achieved by using a dual Traefik instance configuration. This guide walks through the setup of a primary Traefik proxy on **Server 1** with automatic fallback routing to **Server 2**, where a secondary Traefik instance handles services not served by the primary. Both servers also run **Authelia** middleware for centralized forward authentication.

## Overview

- **Server 1** handles all public traffic by default and runs authelia container.
- If a service isn't found on Server 1, Traefik **forwards the request to Server 2**.
- TLS termination occurs on Server 1. That means HTTPS requests from clients are decrypted by Traefik on Server 1.
- Communication between traefik instances is secure (although with self signed cert, which is fine for LAN and my use-case)
- **Authelia** middleware is set up on both traefik instances, ensuring authentication happens regardless of the node handling the request.
- **Redis** is used for session and state management for Authelia
- Auto discovery and traefik labels work on both servers equally.

# SERVER 1 - docker-compose.yml example
```yaml
services:
  traefik:
    image: traefik
    container_name: traefik
    networks:
      - auth
      - default
    ports:
      - target: 443
        published: 443
        protocol: tcp
        mode: host
    security_opt:
      - no-new-privileges:true
    environment:
      - TZ=Europe/Amsterdam
      - CLOUDFLARE_DNS_API_TOKEN=${TRAEFIK_CLOUDFLARE_DNS_API_TOKEN}
      - LEGO_DISABLE_CNAME_SUPPORT=true
      - TRAEFIK_DOMAIN=${TRAEFIK_DOMAIN}
      - SERVER_LAN_IP=${SERVER_LAN_IP}
      - SERVER2_LAN_IP=${SERVER2_LAN_IP}
    command:
      - --log.level=INFO
      - --providers.docker=true
      - --providers.docker.exposedByDefault=false
      - --providers.file.filename=/etc/traefik/config.yml
      - --providers.file.watch=true
      - --entrypoints.websecure.address=:443
      - --entrypoints.websecure.http.tls.domains[0].main=*.${TRAEFIK_DOMAIN}
      - --entrypoints.websecure.http.tls.certresolver=cloudflare
      - --entrypoints.websecure.forwardedHeaders.trustedIPs=127.0.0.1/32,${SERVER2_LAN_IP}
      - --certificatesresolvers.cloudflare.acme.dnschallenge=true
      - --certificatesresolvers.cloudflare.acme.dnschallenge.provider=cloudflare
      - --certificatesResolvers.cloudflare.acme.dnsChallenge.resolvers=1.1.1.1:53,1.0.0.1:53
      - --certificatesResolvers.cloudflare.acme.dnsChallenge.delayBeforeCheck=5
      - --certificatesresolvers.cloudflare.acme.email=peter@${TRAEFIK_DOMAIN}
      - --certificatesresolvers.cloudflare.acme.storage=/etc/traefik/acme.json
      - --serverstransport.insecureskipverify=true
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /volume1/docker/traefik:/etc/traefik
    restart: always

  auth:
    image: authelia/authelia
    container_name: auth
    user: 1337:1337
    networks:
      - auth
    security_opt:
      - no-new-privileges:true
    environment:
      - TZ=Europe/Amsterdam
      - X_AUTHELIA_CONFIG_FILTERS=template
      - TRAEFIK_DOMAIN=${TRAEFIK_DOMAIN}
      - REDIS_PASS=${REDIS_PASS}
    labels:
      - traefik.enable=true
      - traefik.docker.network=auth
      - traefik.http.routers.auth.rule=Host(`auth.${TRAEFIK_DOMAIN}`)
      - traefik.http.routers.auth.entrypoints=websecure
      - traefik.http.middlewares.auth.forwardAuth.address=http://auth:9091/api/authz/forward-auth
      - traefik.http.middlewares.auth.forwardAuth.trustForwardHeader=true
      - traefik.http.middlewares.auth.forwardAuth.authResponseHeaders=Remote-User,Remote-Groups,Remote-Name,Remote-Email
    volumes:
      - /volume1/docker/auth/secrets:/secrets:ro
      - /volume1/docker/auth/config:/config
    restart: always

  auth-redis:
    image: redis:alpine
    container_name: auth-redis
    user: 1337:1337
    networks:
      - auth
    security_opt:
      - no-new-privileges:true
    command: redis-server --requirepass "${REDIS_PASS}"
    volumes:
      - /volume1/docker/auth-redis:/data
    restart: always

networks:
  default:
  auth:
```

# SERVER 1 - traefik config.yml example
```yaml
http:
  routers:
    fallback:
      entryPoints:
        - websecure
      rule: "PathPrefix(`/`)"
      priority: 1
      tls:
        certResolver: cloudflare
      service: forward-to-secondary

  services:
    forward-to-secondary:
      loadBalancer:
        servers:
          - url: "https://{{ env "SERVER2_LAN_IP"}}:443"
        passHostHeader: true
```

# SERVER 1 - authelia configuration.yml example
```yaml
server:
  address: 'tcp4://:9091'

log:
  level: info

identity_validation:
  elevated_session:
    require_second_factor: true
  reset_password:
    jwt_lifespan: '5 minutes'
    jwt_secret: {{ secret "/secrets/jwt_secret.txt" | mindent 0 "|" | msquote }}

totp:
  disable: false
  issuer: 'auth.{{ env "TRAEFIK_DOMAIN" }}'
  period: 30
  skew: 1

password_policy:
  zxcvbn:
    enabled: true
    min_score: 4

webauthn:
  disable: false
  enable_passkey_login: true
  experimental_enable_passkey_uv_two_factors: true
  display_name: 'pd'
  timeout: '60 seconds'
  attestation_conveyance_preference: direct
  selection_criteria:
    attachment: ''
    discoverability: 'preferred'
    user_verification: 'preferred'

authentication_backend:
  file:
    path: '/config/users.yml'
    password:
      algorithm: 'argon2'
      argon2:
        variant: 'argon2id'
        iterations: 3
        memory: 65535
        parallelism: 4
        key_length: 32
        salt_length: 16

access_control:
  default_policy: 'deny'
  rules:
    - domain: '*.{{ env "TRAEFIK_DOMAIN" }}'
      policy: 'bypass'
      resources:
        - '^/api.*'
      networks:
        - '10.10.10.3/32'
    - domain: '*.{{ env "TRAEFIK_DOMAIN" }}'
      policy: 'two_factor'

session:
  name: 'authelia_session'
  secret: {{ secret "/secrets/session_secret.txt" | mindent 0 "|" | msquote }}
  cookies:
    - domain: '{{ env "TRAEFIK_DOMAIN" }}'
      authelia_url: 'https://auth.{{ env "TRAEFIK_DOMAIN" }}'
  redis:
    host: auth-redis
    port: 6379
    password: '{{ env "REDIS_PASS" }}'

regulation:
  max_retries: 4
  find_time: 120
  ban_time: 300

storage:
  encryption_key: {{ secret "/secrets/storage_encryption_key.txt" | mindent 0 "|" | msquote }}
  local:
    path: '/config/db.sqlite3'

notifier:
  disable_startup_check: false
  filesystem:
    filename: '/config/notification.txt'

theme: auto

# OIDC for Synology
#identity_providers:
#  oidc:
#    hmac_secret: {{ secret "/secrets/hmac_secret.txt" | mindent 0 "|" | msquote }}
#    jwks:
#      - key: {{ secret "/secrets/rsa.2048.key" | mindent 10 "|" | msquote }}
#    clients:
#      - client_id: '<client_id>'
#        client_name: 'Synology DSM'
#        client_secret: '<encoded client_secret>'
#        public: false
#        authorization_policy: 'two_factor'
#        redirect_uris:
#          - 'https://server.{{ env "TRAEFIK_DOMAIN" }}'
#        scopes:
#          - 'openid'
#          - 'profile'
#          - 'groups'
#          - 'email'
#        userinfo_signed_response_alg: 'none'
#        token_endpoint_auth_method: 'client_secret_post'
#        consent_mode: implicit
```

# SERVER 2 - docker-compose.yml example
```yaml
services:
  traefik:
    image: traefik
    container_name: traefik
    network_mode: host
    security_opt:
      - no-new-privileges:true
    environment:
      - TZ=Europe/Amsterdam
      - TRAEFIK_DOMAIN=${TRAEFIK_DOMAIN}
    command:
      - --log.level=INFO
      - --providers.docker=true
      - --providers.docker.exposedByDefault=false
      - --providers.file.filename=/etc/traefik/config2.yml
      - --providers.file.watch=true
      - --entrypoints.websecure.address=:443
      - --entrypoints.websecure.http.tls=true
      - --entrypoints.websecure.forwardedHeaders.trustedIPs=127.0.0.1/32,${SERVER_LAN_IP}
      - --serverstransport.insecureskipverify=true
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /volume1/docker/traefik:/etc/traefik
    restart: always
```

# SERVER 2 - traefik config2.yml example
```yaml
http:
  middlewares:
    auth:
      forwardAuth:
        address: https://auth.{{env "TRAEFIK_DOMAIN"}}/api/authz/forward-auth
        trustForwardHeader: true
        authResponseHeaders:
          - Remote-User
          - Remote-Groups
          - Remote-Name
          - Remote-Email
```



And then we can deploy containers with labels:
```yaml
    labels:
      - traefik.enable=true
      - traefik.http.routers.test.rule=Host(`test.${TRAEFIK_DOMAIN}`)
      - traefik.http.routers.test.entrypoints=websecure
      - traefik.http.routers.test.middlewares=auth@file # or just auth in case of server1 since middleware is set with labels instead of file
      - traefik.http.services.test.loadbalancer.server.port=1234
      #- traefik.http.services.test.loadbalancer.server.scheme=https # optional for containers that serve https only on backend
```

Have a great day !
