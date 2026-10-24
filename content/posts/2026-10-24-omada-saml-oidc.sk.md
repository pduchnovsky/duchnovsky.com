+++
categories = ["automatizacia", "homelab", "navody"]
date = "2026-10-24T18:30:00.000+02:00"
description = "Prihlasovanie do Omada Controller cez OIDC poskytovateľa identity pomocou malej SATOSA SAML bridge služby a ACS proxy."
images = ["images/rT4bN9zK2c.jpg"]
slug = "omada-saml-oidc"
tags = ["omada", "saml", "oidc", "docker", "traefik", "identita"]
title = "Prihlasovanie do Omada Controller cez OIDC a SAML bridge"
+++

Chcel som sa do Omada Controller prihlasovať cez existujúceho OIDC poskytovateľa identity. Omada však pri prihlasovaní očakáva SAML. Preto som vytvoril fork projektu [Omada SAML to OIDC Bridge](https://github.com/pduchnovsky/oc-saml-oidc) a prispôsobil ho na prevádzku v homelabe so zameraním na nižšiu spotrebu pamäte. V mojom homelabe klesla pozorovaná spotreba pamäte kontajnera približne z 260 MB na 70 MB. Tieto čísla pochádzajú z mojej zostavy a nie sú univerzálnym benchmarkom.

SATOSA sprostredkuje prihlásenie cez OIDC a bridge poskytuje proxy pre ACS endpoint Omada. Tak možno použiť napríklad Pocket ID alebo Authelia bez zmeny samotného controlleru.

## Tok v prehliadači

1. Používateľ otvorí verejnú URL adresu Omada.
2. Reverse proxy presmeruje požiadavku na koreňovú URL Omada na prihlasovaciu cestu bridge služby.
3. SATOSA presmeruje prehliadač na OIDC poskytovateľa, ktorý používateľa overí.
4. Po overení bridge odošle SAML odpoveď na ACS URL Omada.
5. ACS proxy prepošle požiadavku internému controlleru a podľa potreby upraví presmerovania, cookies a absolútne URL tak, aby používali verejnú Omada doménu.

Controller zostáva dostupný na internej adrese. Prehliadač používa verejnú Omada URL, zatiaľ čo bridge sa pripája priamo k internej adrese controlleru.

## Príklad Compose

Tento príklad spúšťa Omada, databázu a bridge v jednom Compose projekte. Reverse proxy musí byť pripojená do siete `omada`, aby dosiahla controller aj bridge. Databáza používa samostatnú internú sieť a jej port sa nepublikuje na hostiteľa.

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

Súbor s premennými prostredia obsahuje verejné URL a privátny upstream:

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

Doplňte tajný kľúč OIDC klienta a SAML identifikátory z príslušných konfiguračných stránok. Súbor s týmito hodnotami nepridávajte do zdrojového repozitára. Pri prvom spustení bridge vytvorí kľúč na šifrovanie stavu SATOSA a uloží ho do `/data`.

Verzia MongoDB v príklade je zámerná: predvolená inštalácia Omada v6 používa MongoDB 8, ktorá vyžaduje kompatibilný procesor. Ak hostiteľ tieto požiadavky nespĺňa, externú databázu možno použiť ako obchádzku, no kompatibilitu treba overiť pre konkrétnu verziu controlleru. MongoDB 4.4 je po konci životnosti. Pred migráciou si vytvorte zálohu.

## Smerovanie cez reverse proxy

Verejné smerovanie musí rozdeliť požiadavky do štyroch skupín:

- Požiadavka na `omada.example.com/` sa presmeruje na `bridge.example.com/launch/omada`.
- `bridge.example.com/launch/omada` smeruje na bridge.
- `omada.example.com/sso/saml/login` smeruje na ACS handler bridge.
- Ostatné požiadavky na `omada.example.com` smerujú na Omada controller.

OIDC poskytovateľ potrebuje vlastnú verejnú HTTPS doménu. V repozitári sú príklady pre [Traefik](https://github.com/pduchnovsky/oc-saml-oidc/blob/main/examples/traefik-pocket-id.yml) a [nginx](https://github.com/pduchnovsky/oc-saml-oidc/blob/main/examples/nginx-pocket-id.conf), samostatne pre Pocket ID a Authelia.

`OMADA_UPSTREAM_BASES` musí obsahovať interné adresy dostupné z bridge, napríklad `https://oc:8043`. Nepoužívajte v ňom `OMADA_PUBLIC_BASE_URL`. Proxy prepíše absolútne URL iba vtedy, keď začínajú niektorou z nakonfigurovaných interných adries. Ak sa adresy nezhodujú, prehliadač môže po prihlásení skončiť na internej doméne.

Bridge sprostredkuje iba prihlasovanie v prehliadači a odoslanie SAML odpovede na ACS. Nenahrádza porty potrebné na adopciu a správu zariadení Omada; tie musia zostať dostupné pre zariadenia podľa konfigurácie siete. Databázu nikdy nevystavujte verejne.
