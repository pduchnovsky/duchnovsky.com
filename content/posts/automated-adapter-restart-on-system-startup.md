+++
categories = ["automation", "guides", "scripts"]
date = 2023-02-27T22:17:08Z
description = "Workaround for i225-v & i226-v Intel Network Adapter problems"
externalLink = ""
images = ["/images/ylrr0ok5p7-1.png"]
series = []
slug = "automated-adapter-restart"
tags = ["powershell", "task scheduler", "ethernet"]
title = "Automated Adapter Restart on System Startup"

+++

Yes, damnit !

Since I bought a new z790 board I was experiencing problems where my Ethernet network adapter was not connected after startup, solution was to restart the adapter and everything was peachy.

This is due to a [bug on Intel side](https://www.guru3d.com/news-story/intel-is-experiencing-network-issues-the-i226-v-controller-is-prone-to-connection-loss.html), which apparently is very hard to solve (/s).

And since I am lazy engineer who doesn't want to perform tedious tasks every day, I automated this workaround, which essentially creates a task which executes powershell command on startup, this command or script checks whether the adapter is up and if not then restarts it.

Change the path to your powershell.exe if needed and change variable AdapterName if needed, then execute this in powershell while running as admin.

Simple as that, enjoy !

```powershell
# Restart Adapter when not UP (intel i225-v and i226-v issue workaround)
# Script developed by pduchnovsky
# https://duchnovsky.com/2023/02/automated-adapter-restart/
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
