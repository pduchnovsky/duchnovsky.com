+++
description = "pduchnovsky | Something little about my homelab"
images = ["images/selfhosting.png"]
slug = "homelab"
title = "HomeLab"
+++

![-](images/homelab.jpg "this is my playground")

{{< notice info >}}
My HomeLab started as a side project and has quietly turned into my main hobby over the past few years. There's something genuinely satisfying about tweaking and improving the setup, and I run most of it on Docker, hosting a bunch of services for myself and my family.

The core of it all is Home Assistant, which I set up and configured by hand across my entire house. It handles a lot: automatically managing a dehumidifier and heater in the standalone garage, ventilating the house based on CO2 sensor readings, detecting water leaks and shutting off the supply automatically, controlling the external blinds and garage door, and keeping an eye on things with full security and monitoring (seven cameras plus a house-wide alarm system). On top of that, I've integrated Zigbee power plugs, smoke detectors, BLE humidity and temperature sensors, ESPHome devices, BLE proxies, IR blasters, and zigbee plugs for the garage. The network itself runs on TP-Link Omada gear, managed through the Omada Controller, and it's split into core, IoT, and guest VLANs with stateful ACL rules between them. I've also set up a proxy/relay for multicast traffic between the IoT and Core VLANs, so Home Assistant can still discover devices across the segmented network.

3-2-1 backups are non-negotiable — they keep my data safe and limit the damage if anything ever goes wrong.

For DNS and ad/tracking blocking, I run a highly available AdGuard Home setup. And since I clearly enjoy overengineering things, I also have a fast fiber connection at 1000 Mbps down / 500 Mbps up to back it all up.

My docker-compose.yml is currently sitting at over 775 lines :)

At this point, my HomeLab isn't just a technical playground — it's basically a reflection of how much I enjoy this stuff. ❤️
{{< /notice >}}

![-](images/hass.png "homeassistant dashboard")
