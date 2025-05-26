+++
description = "pduchnovsky | Something little about my homelab"
images = ["images/selfhosting.png"]
slug = "homelab"
title = "HomeLab"
+++

![-](images/homelab.jpg "this is my playground")

{{< notice info >}}
My HomeLab, a dedicated space for experimentation and technological exploration, has evolved into my primary hobby over the past few years. I derive immense satisfaction from fine-tuning and enhancing my setup, leveraging Docker to host an array of services for both personal use and family benefit.

At the heart of my HomeLab lies HomeAssistant, a meticulously configured home automation system that I personally established throughout my entire residence. Among its capabilities are automatic management of a dehumidifier and heater in the standalone garage, intelligent house ventilation based on CO2 sensor readings, water leak detection with automatic shutoff, automation for external blinds, garage door control, and comprehensive security and monitoring (including seven cameras and a house-wide alarm system). Additionally, I’ve integrated Zigbee power plugs, smoke detectors, BLE humidity and temperature sensors, ESPhome devices, BLE Proxies, IR blasters, and Wi-Fi plugs for the garage. My network architecture, composed of TP-Link Omada devices, ensures ease of management through the Omada Controller. It is thoughtfully segmented into core, IoT, and guest VLANs, safeguarded by stateful ACL rules. Furthermore, I’ve implemented a proxy/relay mechanism to facilitate multicast communication between IoT and Core VLANs, enabling seamless device discovery by HomeAssistant.

3-2-1 backups are a must, ensuring data protection and minimizes the impact of data loss incidents.

For DNS queries and ad/tracking blocking, I maintain a highly available Adguard Home. And, as a testament to my passion for high-speed connectivity, I proudly enjoy a blazing 1000 Mbps download and 500 Mbps upload connection via fiber.

My docker-compose.yml file currently reads over 550 lines and it's gonna be way more pretty soon I gather :)

In summary, my HomeLab is not just a technical playground; it’s an embodiment of my enthusiasm and commitment to technological excellence. ❤️
{{< /notice >}}

![-](images/hass.jpg "homeassistant dashboard")
