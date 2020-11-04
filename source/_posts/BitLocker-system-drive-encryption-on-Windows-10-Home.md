---
title: BitLocker system drive encryption on Windows 10 Home
date: 2020-10-02 08:22:44
thumbnail: /images/2020-10-02-23-34-57.png
tags:
  - guide
  - bitlocker
  - manage-bde
  - workaround
  - windows 10
---
As of time of writing this article, Windows 10 Home does not support BitLocker GUI and that's *fine*, they *probably* don't want home users to lose access to their data in case of wrong configuration, but there is countless businisses using Windows 10 Home, mostly due to cost and many of small businesses could not utilize features of Windows 10 Pro.
If you manage small business IT infrastructure, or Windows 10 Home in general, you must find a way on how to protect their data even on devices that come with Windows 10 Home.

So here we go.. :)

##### Prerequisites

- Disk with GPT (GUID Partition Table)
- Dedicated TPM module (v1.2+) or enabled Intel PTT in BIOS

Now how to check this ?  
(Run all commands from now on in cmd.exe as admin)

``` batch
powershell Get-Disk 0 | findstr GPT && echo This is a GPT system disk!
powershell Get-WmiObject -Namespace "root/cimv2/security/microsofttpm" -Class WIN32_tpm | findstr "IsActivated IsEnabled IsOwned SpecVersion"
```

This must return **3 True values** and **spec version 1.2** or higher (first number)

![screenshot](/images/2020-10-02-23-35-44.png)

##### If your device meets the prerequisites

Access Windows 10 Advanced Startup Options  

Then go **Troubleshoot > Advanced Options > Command Prompt**

Upon boot, log in with your account that has admin privileges and type this to start encryption:

``` batch
manage-bde -on c: -used -RemoveVolumeShadowCopies
```

This will also remove Volume Shadow Copies, this is a prerequisite for enabling encryption.

Now close the command prompt and continue to windows where perform following commands:

``` batch
manage-bde c: -protectors -add -rp -tpm
manage-bde -protectors -enable c:
manage-bde -protectors -get c: > %UserProfile%\Desktop\BitLocker-Recovery-Key.txt
```

❗ **Back up your `BitLocker-Recovery-Key.txt`** ❗
(which will be located on your desktop)

And voila, data on your system drive will soon be encrypted and protected  
To check status of encryption use command: `manage-bde -status`

![screenshot](/images/2020-10-02-23-36-17.png)
