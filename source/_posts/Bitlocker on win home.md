---
title: BitLocker system drive encryption on Windows 10 Home
date: 2020-10-02
thumbnail: thumbnail/bitlocker.jpg
tags:
- guide
- bitlocker
- manage-bde
- windows 10 home
- workaround
---
>'Officially' Windows 10 Home does not support BitLocker GUI and that's *fine*, they *probably* don't want home users to lose access to their data..
>...however, if you manage small business IT infrastructure you must find a way on how to protect company data even on devices that come with Windows 10 Home.

So here we go.. :)

>**Prerequisites**
>
> - Disk with GPT (GUID Partition Table)
> - Dedicated TPM module (v1.2+) or enabled Intel PTT in BIOS

Now how to check this ?

(Run all commands from now on in cmd.exe as admin)
``` batch
    powershell Get-Disk 0 | findstr GPT && echo This is a GPT system disk!
    powershell Get-WmiObject -Namespace "root/cimv2/security/microsofttpm" -Class WIN32_tpm | findstr "IsActivated IsEnabled IsOwned SpecVersion"
```
> This must return **3 True** values and spec version **1.2** or higher (first number).

**If your device meets the prerequisites**  
Access windows 10 Advanced Startup Options  
 (*press reboot while holding shift button*)  
then go in to **Troubleshoot > Advanced Options > Command Prompt**

Login with your account that has admin privileges and type this to start encryption:
``` batch
    manage-bde -on c: -used
```
Once this is done, close the command prompt and continue to windows where perform following:
``` batch
    manage-bde c: -protectors -add -rp -tpm
    manage-bde -protectors -enable c:
    manage-bde -protectors -get c: > %UserProfile%\Desktop\BitLocker-Recovery-Key.txt
```

> ❗ **Backup your BitLocker-Recovery-Key.txt which will be located on your desktop.** ❗

And voila, data on your system drive will soon be encrypted and protected  
To check status of encryption use command: `manage-bde -status`