+++
description = "pduchnovsky | Niečo málo o mojom homelabe"
images = ["images/selfhosting.png"]
slug = "homelab"
title = "HomeLab"
+++

![-](images/homelab.jpg "toto je moje ihrisko")

{{< notice info >}}
Homelab som si pôvodne založil ako vedľajší projekt, ale za posledných pár rokov sa z neho nepozorovane stal môj hlavný koníček. Doťahovanie a vylepšovanie setupu mi naozaj robí radosť a väčšinu vecí beží na Docker, kde hostím kopu služieb pre seba aj pre rodinu.

Srdcom celého homelabu je HomeAssistant, ktorý som si vlastnoručne nastavil a rozbehol po celej domácnosti. Stará sa o naozaj veľa vecí: automaticky riadi odvlhčovač a ohrievač v samostatnej garáži, vetra dom podľa hodnôt z CO2 senzorov, detekuje únik vody a v prípade potreby automaticky uzavrie prívod, ovláda vonkajšie žalúzie a garážovú bránu a stará sa o kompletné zabezpečenie a monitoring (sedem kamier a poplachový systém pre celý dom). K tomu som ešte zapojil Zigbee zásuvky, detektory dymu, BLE senzory vlhkosti a teploty, ESPHome zariadenia, BLE proxy, IR blastery a Wi-Fi zásuvky v garáži. Sieť mám postavenú na zariadeniach TP-Link Omada, ktoré spravujem cez Omada Controller, a je rozdelená do Core, IoT a Guest VLAN so stavovými ACL pravidlami medzi nimi. Aby aj napriek tomuto rozdeleniu fungovalo objavovanie zariadení, implementoval som proxy/relé pre multicast komunikáciu medzi IoT a Core VLAN, takže HomeAssistant bez problémov nájde zariadenia aj cez segmentovanú sieť.

Zálohy podľa pravidla 3-2-1 sú samozrejmosť – chránia dáta a minimalizujú dopad, ak sa niečo pokazí.

Na DNS dotazy a blokovanie reklám/trackingu mám vysoko dostupný AdGuard Home. A keďže to s vecami okolo siete asi trochu preháňam, mám aj rýchle optické pripojenie s rýchlosťou 1000 Mbps sťahovanie / 500 Mbps odosielanie.

Môj docker-compose.yml súbor má momentálne cez 750 riadkov :)

Takže môj HomeLab už dávno nie je len technické ihrisko – je to vlastne odraz toho, ako ma táto téma baví. ❤️
{{< /notice >}}

![-](images/hass.png "homeassistant dashboard")
