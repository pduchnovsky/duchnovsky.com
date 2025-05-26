+++
description = "pduchnovsky | Niečo málo o mojom homelabe"
images = ["images/selfhosting.png"]
slug = "homelab"
title = "HomeLab"
+++

![-](images/homelab.jpg "toto je moje ihrisko")

{{< notice info >}}
Môj homelab, vyhradený priestor na experimentovanie a technologické skúmanie, sa za posledných pár rokov stal mojím hlavným koníčkom. Mám obrovskú spokojnosť z dolaďovania a vylepšovania môjho setupu a využívam Docker na hosťovanie množstva služieb pre osobné použitie aj pre rodinu.

V srdci môjho homelabu leží HomeAssistant, precízne nakonfigurovaný systém domácej automatizácie, ktorý som osobne zaviedol do celej domácnosti. Medzi jeho schopnosti patrí automatické riadenie odvlhčovača a ohrievača v samostatnej garáži, inteligentné vetranie domu na základe hodnôt CO2 senzorov, detekcia úniku vody s automatickým vypnutím, automatizácia vonkajších žalúzií, ovládanie garážovej brány a komplexné zabezpečenie a monitorovanie (vrátane siedmich kamier a celoplošný poplachový systém). Okrem toho som integroval napájacie zástrčky Zigbee, detektory dymu, snímače vlhkosti a teploty BLE, zariadenia ESPhome, proxy BLE, IR blastery a zástrčky Wi-Fi v garáži. Moja sieťová architektúra zložená zo zariadení TP-Link Omada zaisťuje jednoduchú správu prostredníctvom Omada Controller. Je premyslene rozdelená do Jadro, IoT a Hostia VLAN, chránených stavovými pravidlami ACL. Okrem toho som implementoval mechanizmus proxy/relé na uľahčenie multicastovej komunikácie medzi IoT a Core VLAN, čo umožňuje bezproblémové zisťovanie zariadení pomocou HomeAssistant.

Nevyhnutnosťou sú zálohy 3-2-1, ktoré zaisťujú ochranu údajov a minimalizujú vplyv incidentov straty údajov.

Pre dotazy DNS a blokovanie reklám/sledovania udržiavam vysoko dostupný Adguard Home. A ako dôkaz mojej vášne pre vysokorýchlostné pripojenie si hrdo užívam pripojenie s rýchlosťou sťahovania 1000 Mbps a odosielania 500 Mbps cez optiku.

Môj docker-compose.yml súbor má momentálne viac ako 550 riadkov a čoskoro ich bude zrejme oveľa viac :)

Stručne povedané, môj HomeLab nie je len technické ihrisko; je stelesnením môjho nadšenia a záväzku k technologickej dokonalosti. ❤️
{{< /notice >}}

![-](images/hass.jpg "homeassistant dashboard")
