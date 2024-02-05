+++
categories = ["automatizacia", "navody", "scripty"]
date = 2023-02-27T22:17:08
description = "Riešenie problémov so sieťovým adaptérom Intel i225-v a i226-v"
externalLink = ""
images = ["/images/ylrr0ok5p7-1.png"]
series = []
slug = "automaticky-restart-adaptera"
tags = ["powershell", "task scheduler", "ethernet"]
title = "Automatizovaný reštart adaptéra pri spustení systému"

+++

Áno, sakra!

Od kúpy novej dosky z790 som mal problémy, keď môj ethernetový sieťový adaptér nebol po spustení pripojený, riešením bolo reštartovať adaptér a všetko bolo krásne.

Je to kvôli [chybe na strane Intelu](https://www.guru3d.com/news-story/intel-is-experiencing-network-issues-the-i226-v-controller-is-prone-to-connection-loss.html), ktorú je zrejme veľmi ťažké vyriešiť (/s).

A keďže som lenivý inžinier, ktorý nechce vykonávať únavné úlohy každý deň, zautomatizoval som toto riešenie, ktoré v podstate vytvorí úlohu, ktorá vykoná príkaz powershell pri štarte, tento príkaz alebo skript skontroluje, či je adaptér zapnutý a ak nie, potom ho reštartuje.

V prípade potreby zmeňte cestu k vášmu powershell.exe a ak je to potrebné, zmeňte premennú AdapterName, potom vykonajte tieto príkazy v prostredí powershell ako správca/admin.

Jednoduché, užite si to!

```powershell
# Automatizovany restart adaptera ak nie je pripojeny (intel i225-v a i226-v problem)
# Script vytvoril pduchnovsky
# https://duchnovsky.com/2023/02/automaticky-restart-adaptera/
$AdapterName = "Ethernet"
$PowerShellPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
$Argument = "-command `"Get-NetAdapter $AdapterName | ? status -ne up | Restart-NetAdapter`""
$Name = "Restart Adapter"
$Trigger = New-ScheduledTaskTrigger -AtStartup
$Action = New-ScheduledTaskAction -Execute $PowerShellPath $Argument
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -ExecutionTimeLimit 0
$Principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
Register-ScheduledTask -TaskName $Name -Trigger $Trigger -Action $Action -Settings $Settings -Principal $Principal
```
