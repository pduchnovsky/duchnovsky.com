+++
categories = ["linux", "navody", "skripty"]
date = 2024-02-05T23:10:08
description = "Rýchle a jednoduché pravidlá firewallu pomocou nftables na blokovanie podľa geografickej polohy na Ubuntu 22.04"
externalLink = ""
images = ["images/8s7dfas65f.png"]
series = []
slug = "nftables-firewall-ubuntu-22-04-sk"
tags = ["nftables", "geoblokacia", "ubuntu"]
title = "Rýchle a jednoduché blokovanie podľa geografickej polohy na Ubuntu 22.04"

+++

Chcel som sa s vami podeliť o rýchly skript na nastavenie veľmi základnej geoblokácie na porte 443. Je užitočný pre webové servery, kde nepotrebujete prístup z celého sveta :)  
Samozrejme toto stačí len pre servery kde je forwardovany len port 443, pre servery v DMZ je potrebné vačšie úsilie.

```bash
#!/bin/bash
# Fast and simple Geo Blocking on Ubuntu 22.04
# Script developed by pduchnovsky
# https://duchnovsky.com/2024/02/nftables-firewall-ubuntu-22-04/
allowed_countries="sk"  # List of allowed countries codes, space separated
sudo nft delete table inet filter 2>/dev/null # Delete the table we create in steb below, useful in case of re-running this
sudo nft add table inet filter # Add new inet table
sudo nft add chain inet filter INPUT { type filter hook input priority 0\; } # Add new chain
sudo nft add set inet filter LOCAL_CIDR { type ipv4_addr\; flags interval\; } # Creates set for local IPs
sudo nft add element inet filter LOCAL_CIDR { 127.0.0.0/8,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16 } # Add IP CIDR to the set
sudo nft add rule inet filter INPUT ip protocol tcp ip saddr @LOCAL_CIDR tcp dport 443 counter accept # Accepts the connection from defined set addresses via tcp port 443
for countrycode in $allowed_countries;do
    # Download aggregated list per country
    wget -q --no-check-certificate https://www.ipdeny.com/ipblocks/data/aggregated/${countrycode}-aggregated.zone -O /tmp/nftables-${countrycode}.txt
    sudo nft add set inet filter ${countrycode} { type ipv4_addr\; flags interval\; } # Creates set per country
    sudo nft add element inet filter ${countrycode} { $(tr "\n" "," < /tmp/nftables-${countrycode}.txt) } # Adds IPs from aggregated list to the set
    sudo nft add rule inet filter INPUT ip protocol tcp ip saddr @${countrycode} tcp dport 443 counter accept # Accepts the connection from defined set addresses via tcp port 443
done
sudo nft add rule inet filter INPUT tcp dport 443 drop # drop connection via tcp 443 by default
```

Nooo, Teraz je tento skript len jednorazová záležitosť, nepretrvá pri reštarte, takže navrhujem uložiť tento skript napríklad do `/usr/local/bin/geoblock`, nastaviť ho ako spustiteľný `chmod +x /usr/ local/bin/geoblock` a potom ho jednoducho pridajte do svojho crontabu, aby sa spustil po reštarte `(crontab -l 2>/dev/null; echo "@reboot /usr/local/bin/geoblock") | crontab -`  
Týmto spôsobom sa nebudete musieť zaoberať pravidlami iných služieb, ako je docker alebo iné, pretože nepracujete so samotnou službou nfttables a jej konfiguračným súborom.  
A to je všetko.  
