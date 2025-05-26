+++
categories = ["linux", "guides", "scripts"]
date = 2024-02-05T23:10:08
description = "Fast and simple firewall rules using nftables for Geo Blocking on Ubuntu 22.04"
externalLink = ""
images = ["images/8s7dfas65f.png"]
series = []
slug = "nftables-firewall-ubuntu-22-04"
tags = ["nftables", "geoblock", "ubuntu"]
title = "Fast and simple Geo Blocking on Ubuntu 22.04"

+++

Just wanted to share quick script to enable very basic geoblocking @ port 443, useful for web facing server where you don't need access from the whole world :)  
Of course, this is only sufficient for servers where only port 443 is forwarded, for servers in the DMZ more effort is required.

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

Now, this script is just one time thing, it won't persist the reboot so my suggestion is to save this script to `/usr/local/bin/geoblock` for example, set it as executable `chmod +x /usr/local/bin/geoblock` and then simply add it to your crontab so it executes after reboot `(crontab -l 2>/dev/null; echo "@reboot /usr/local/bin/geoblock") | crontab -`  
This way you won't have to deal with other services rules, such as docker or else, since you are not working with nfttables service itself and its config file.  
And that's it.
