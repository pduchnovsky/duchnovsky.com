+++
categories = ["automatizacia", "homelab", "navody"]
date = "2026-10-24T18:12:00.000+02:00"
description = "Ľahké API kompatibilné s Glances pre Homepage, vytvorené ako malá Go služba namiesto celého monitorovacieho riešenia."
images = ["images/x6GqP8vL2m.jpg"]
slug = "homepage-stats"
tags = ["docker", "golang", "glances", "homepage", "metriky"]
title = "Malý server metrík kompatibilný s Glances pre Homepage"
+++

Chcel som, aby widget Glances v aplikácii [Homepage](https://gethomepage.dev/) zobrazoval niekoľko metrík hostiteľa bez toho, aby som kvôli tomu musel prevádzkovať celý server Glances. Preto som vytvoril [homepage-stats](https://github.com/pduchnovsky/homepage-stats), malú Go službu, ktorá poskytuje tie Glances API endpointy, ktoré widget potrebuje.

Zámerne nejde o plnohodnotnú náhradu Glances. Služba poskytuje obmedzenú sadu metrík Linuxu ako statická Go binárka v minimálnom neprivilegovanom kontajneri `scratch`.

## Čo poskytuje

Služba implementuje Glances endpointy používané widgetom:

- Využitie CPU a priemerné zaťaženie systému
- Celkovú a využitú pamäť
- Kapacitu a využitie súborového systému
- Teploty zo senzorov, ak ich hostiteľ sprístupňuje
- Čas prevádzky a základné informácie o systéme
- Stručný súhrn `quicklook` a endpoint `/health` na kontrolu dostupnosti

Endpointy služby sú dostupné na cestách `/api/4/<endpoint>`, `/api/3/<endpoint>` a `/<endpoint>`. Cesta v3 je iba aliasom pre túto podmnožinu API, takže služba nie je plne kompatibilná s Glances v3. Údaje o CPU sa vzorkujú raz za sekundu; ostatné metriky sa načítajú až pri požiadavke.

V jednom nasadení v homelabe som nameral približne 10 MB RAM, zatiaľ čo minimálne nasadenie Glances spotrebovalo asi 100 MB. Nešlo o kontrolovaný benchmark a výsledok sa môže líšiť podľa hostiteľa a prostredia.

## Compose

Predvolený Compose súbor sprístupňuje port služby iba na localhost. Koreňový súborový systém kontajnera je iba na čítanie a kontajner nemá pridelené Linux capabilities:

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

`STATS_IMAGE` nastavte na tag vydania alebo digest obrazu. `STATS_BIND_IP` určuje, na ktorej adrese hostiteľa sa port sprístupní. Predvolene je dostupný iba cez localhost. Ak Homepage beží v inom kontajneri, pripojte obe služby do spoločnej Docker siete a použite `http://stats:61208`. Pri prístupe cez LAN povoľte firewallom prístup iba hostiteľovi Homepage.

Do Homepage pridajte widget:

```yaml
- glances:
    url: http://stats:61208
    version: 4
    cpu: true
    mem: true
    cputemp: true
    disk: /
    uptime: true
    label: Môj server
```

## Súborový systém a senzory

Predvolene sa údaje o disku týkajú koreňového súborového systému kontajnera (`/`), ktorým môže byť jeho overlay filesystem, nie dátový disk hostiteľa. Ak chcete sledovať konkrétny súborový systém hostiteľa, pripojte ho iba na čítanie a nastavte `STATS_DISK_PATH` na cestu vo vnútri kontajnera:

```yaml
environment:
  - STATS_DISK_PATH=/hostfs
volumes:
  - /cesta/na/hostitelovi:/hostfs:ro
```

API zobrazí pripojený súborový systém ako `/`, čo zodpovedá nastaveniu `disk: /` vo widgete Homepage. Teploty závisia od senzorov hostiteľa a podpory v jadre. Služba nemá vlastné prihlasovanie ani TLS, preto ju nechajte v dôveryhodnej sieti a nevystavujte ju verejne.

Služba číta CPU, systémové zaťaženie a pamäť z počítadiel jadra Linuxu, ktoré vidí kontajner. Nejde o využitie zdrojov kontajnera podľa cgroups, takže tieto údaje opisujú hostiteľa, nie samotný kontajner.

Zdrojový kód je na [github.com/pduchnovsky/homepage-stats](https://github.com/pduchnovsky/homepage-stats).
