+++
categories = ["guides"]
date = 2020-10-02T23:00:00Z
description = "Ak spravujete IT infraštruktúru pre malé podniky alebo všeobecne Windows 10 Home, musíte nájsť spôsob, ako chrániť ich údaje a to aj na zariadeniach, ktorých súčasťou je systém Windows 10 Home."
externalLink = ""
images = ["/images/YLrR0Ok5p7.png"]
slug = "sifrovanie-bitlocker"
tags = ["windows 10", "bitlocker", "cmd"]
title = "BitLocker šifrovanie systémovej jednotky vo Windows 10 Home"

+++
V čase písania tohto článku Windows 10 Home nepodporuje grafické rozhranie BitLocker a to je *v poriadku*, *pravdepodobne* nechcú, aby domáci používatelia stratili prístup k svojim údajom v prípade nesprávnej konfigurácie, ale existuje nespočetné množstvo firiem, ktoré používajú Windows 10 Home, hlavne z dôvodu nákladov a taktiež, že nevedia využiť funkcie systému Windows 10 Pro.
Ak spravujete IT infraštruktúru pre malé podniky alebo všeobecne Windows 10 Home, musíte nájsť spôsob, ako chrániť ich údaje a to aj na zariadeniach, ktorých súčasťou je systém Windows 10 Home.

To riešenie slúži aj v prípade použitia Win10 Pro, ale pri chybe: „Na dokončenie šifrovania tohto zariadenia potrebujete účet Microsoft. “ 

Takže ideme na to .. :)

### Predpoklady

- Disk s GPT (tabuľka oddielov GUID)
- Vyhradený modul TPM (v1.2 +) alebo zapnutý Intel PTT v systéme BIOS

Ako to teraz skontrolovať?
(Všetky príkazy spustite odteraz v cmd.exe ako správca)

``` batch
powershell Get-Disk 0 | findstr GPT && echo This is a GPT system disk!
powershell Get-WmiObject -Namespace "root/cimv2/security/microsofttpm" -Class WIN32_tpm | findstr "IsActivated IsEnabled IsOwned SpecVersion"
```

Toto musí vrátit **3 'True' hodnoty** a **spec version 1.2** alebo vyššiu (prvé číslo)

![screenshot ><](/images/reX0MvuNqe.png)

### Ak vaše zariadenie spĺňa predpoklady

Prístupte k rozšíreným možnostiam spustenia systému Windows 10

Potom choďte **Riešenie problémov> Rozšírené možnosti> Príkazový riadok**

Pri štarte sa prihláste pomocou svojho účtu, ktorý má oprávnenie správcu a začnite šifrovanie zadaním tohto príkazu:

``` batch
manage-bde -on c: -used -RemoveVolumeShadowCopies
```

Týmto sa tiež odstránia tieňové kópie zväzku, čo je nevyhnutným predpokladom pre povolenie šifrovania.

Teraz zatvorte príkazový riadok a pokračujte do windowsu, kde vykonajte nasledujúce príkazy:

``` batch
manage-bde c: -protectors -add -rp -tpm
manage-bde -protectors -enable c:
manage-bde -protectors -get c: > %UserProfile%\Desktop\BitLocker-Recovery-Key.txt
```

❗ **Zálohujte súbor `BitLocker-Recovery-Key.txt`** ❗
(ktorý bude umiestnený na ploche)

A voila, dáta na vašom systémovom disku budú čoskoro zašifrované a chránené
Na kontrolu stavu šifrovania použite príkaz: `manage-bde -status`

![screenshot ><](/images/N7dlS8tkeJ.png)