+++
description = "pduchnovsky | Something little about my homelab"
images = []
slug = "homelab"
title = "HomeLab"
+++

![-](photos/homelab.jpg "this is my playground")

{{< notice info >}}
This is my little HomeLab, which became essentially my main hobby in the recent years.  
I love tinkering around and improving my setup, using mainly docker to host several services for myself and my family.  
Running HomeAssistant for home automation which I fully set up myself for the entire house, such as automatic dehumidifier and heater for standalone garage, automatic house ventilation based on CO2 sensors, water leak detection and automatic water shut off, automation for external blinds, garage door automation, security and monitoring (7 cameras, house-wide alarm), zigbee power plugs and smoke detectors, BLE humidity and temperature sensors, ESPhome devices/sensors and BLE Proxies, IR blasters, some wifi plugs for garage, power monitoring, heat pump monitoring, etc.  
My network stack consists of tp-link Omada devices due to easy manageability using Omada Controller as well as seamless integration and is separated simply - core, IoT and guest vlans, protected using stateful ACL rules in between them, as well as running proxy/relay for multicast between IoT and Core vlans so devices are discoverable by HomeAssistant :)  
Running highly available Adguard Home for DNS queries and ads/tracking blocking.  
Rocking 1000Mbit down and 500Mbit up connection via fiber 🤘  

I just love it ❤️  :)
{{< /notice >}}

![-](photos/hass.jpg "homeassistant dashboard")
