+++
categories = ["scripty"]
date = 2020-11-10T23:00:00
description = "Toto je jeden z problémov, s ktorými sa stretávame v prípade Bitbucket Pipelines, ak dôjde k niekoľkým zlúčeniam revízi do našich hlavných branches v krátkom časovom období, v zásade sa rolloutne iba prvá, pretože bitbucket pozastaví zvyšok."
externalLink = ""
images = ["/images/LS2lziJFHP.png"]
slug = "bitbucket-pipelines-monitorovanie"
tags = ["bitbucket", "pipelines", "monitorovanie", "bash"]
title = "Monitorovanie pozastavených Bitbucket pipelines"

+++

Toto je jeden z problémov, s ktorými sa stretávame v prípade Bitbucket Pipelines, ak dôjde k niekoľkým zlúčeniam revízii do našich hlavných branches v krátkom časovom období, v zásade sa rolloutne iba prvá, pretože bitbucket pozastaví zvyšok.

To je z hľadiska logiky CI/CD do istej miery pochopiteľné a je to v poriadku, ak máte naraz iba jednu veľkú revíziu, ale to spôsobuje početné problémy tímom, kde viac ľudí pracuje na paralelných funkciách.

Bohužiaľ sa zdá, že Atlassian nedáva bitbucket pipelines veľkú prioritu, pretože problém je dobre známy už viac ako 2 roky podľa [BCLOUD-16304](https://jira.atlassian.com/browse/BCLOUD-16304) a aktívne sa na ňom nepracuje, aj keď má tento problém viac ako 100 hlasov.

Musel som vymyslieť nejaké riešenie a tak som vytvoril jednoduchý [BASH](<https://en.wikipedia.org/wiki/Bash_(Unix_shell)>) skript, ktorý funguje s Bitbucket API.

Tento skript používa na overenie autentifikáciu bitbucket (`BITBUCKET_CREDS`) s [heslom aplikácie](https://bitbucket.org/account/settings/app-passwords/) a robí nasledujúce:

1. Pre každé repo definované v `BITBUCKET_REPO_LIST` získa zoznam potrubí zahájených ako `MANUAL` alebo `PUSH` a uloží ich do súboru _api_response.json_.
2. Pre každú branch z `BITBUCKET_BRANCH_LIST` skontroluje, či existujú pipes v `RUNNING` alebo `PENDING` statuse, ak existujú, nerobí nič, ale ak v súčasnosti žiadne nebežia, skontroluje, či je posledná pipe `HALTED` a ak je, spustí novú na základe jej commitu a tým zaistí, aby sa vždy rolloutli najnovšie zmeny.

Celkom jednoduchý skript, ktorý však ušetrí veľa úsilia. Používame ho ako monitorovací skript, ktorý sa spúšťa každú minútu.

**Požiadavky**:

- nainštalovaný balík [jq](https://stedolan.github.io/jq/download/) v systéme, kde je spúšťaný skript.

```shell
#!/bin/bash
# Script developed by pduchnovsky
# https://duchnovsky.com/2020/11/bitbucket-pipelines-monitoring/

#Variables definition:
BITBUCKET_CREDS="username:app_password"
BITBUCKET_WORKSPACE="workspace-name"
BITBUCKET_REPO_LIST="repo-1 repo-2 repo-3"
BITBUCKET_BRANCH_LIST="primary secondary tertiary"

#The actual hard work:
for BITBUCKET_REPO_SLUG in $BITBUCKET_REPO_LIST; do
    curl -s -u $BITBUCKET_CREDS \
    "https://api.bitbucket.org/2.0/repositories/$BITBUCKET_WORKSPACE/$BITBUCKET_REPO_SLUG/pipelines/?sort=-created_on&pagelen=20"|
    jq -r '[.values[] | select((.trigger.name == "PUSH" or .trigger.name == "MANUAL"))]' > api_response.json
    for BITBUCKET_BRANCH in $BITBUCKET_BRANCH_LIST; do
        if [[ $(jq -r '.[]| select(.target.ref_name == "'$BITBUCKET_BRANCH'")|
                select((.state.stage.name == "RUNNING") or (.state.stage.name == "PENDING"))' api_response.json) ]]
        then
            echo "$BITBUCKET_REPO_SLUG/$BITBUCKET_BRANCH -> There is a deployment in progress, doing nothing"
        else
            if [[ $(jq -r '[.[]| select(.target.ref_name == "'$BITBUCKET_BRANCH'")]|
                    .[0]|select(.state.stage.name == "HALTED")' api_response.json) ]]
            then
                echo "$BITBUCKET_REPO_SLUG/$BITBUCKET_BRANCH -> The latest deployment is paused, triggering new deployment"
                curl -X POST -is -u $BITBUCKET_CREDS -H 'Content-Type: application/json' \
                    "https://api.bitbucket.org/2.0/repositories/$BITBUCKET_WORKSPACE/$BITBUCKET_REPO_SLUG/pipelines/" \
                    -d '{ "target": { "ref_type": "branch", "type": "pipeline_ref_target", "ref_name": "'$BITBUCKET_BRANCH'" } }'
            else
                echo "$BITBUCKET_REPO_SLUG/$BITBUCKET_BRANCH -> Latest pipeline is not paused, doing nothing"
            fi
        fi
    done
done
```
