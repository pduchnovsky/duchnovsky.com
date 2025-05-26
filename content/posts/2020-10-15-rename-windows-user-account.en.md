+++
categories = ["guides"]
date = 2020-10-15T23:00:00
description = "There are few cases where you'd like to rename somebody's user account as well as profile folder and I will explain on how to do it properly."
externalLink = ""
images = ["images/ehO75Qfj6i.png"]
slug = "rename-user-account"
tags = ["windows 10", "cmd", "regedit"]
title = "Rename Windows user account and profile folder"

+++
There are few cases where you'd like to rename somebody's user account as well as profile folder and I will explain on how to do it properly.

First of all, let's start with..

#### Prerequisites

* The account is local
  * You have to temporarily disconnect it from Microsoft account
  * This is not easily possible for Azure/AD accounts
* The target account name does not exist and it never existed
* You have access to another admin account on the same machine

If you are ready with above..

### Let's get started

For this scenario let's rename imaginary account _'badname'_ to _'goodname'_, with help of another admin account _'administrator'_.

1. Log in as _administrator_
2. Go to **Control Panel > User Accounts > Manage another account > Choose _badname_ > Change Name**
3. Now rename the account to _goodname_
4. Rename folder **C:\\Users\\_badname_** to **C:\\Users\\_goodname_**
5. Do batch search and replace in the registry, I found it was the easiest using tool like [Advanced Regedit (win32)](https://sourceforge.net/projects/regedt33/)

* Upon opening the program press Ctrl + H
* Follow example below and define Start and End keys:
  ![screenshot](images/RqBv1kATBR.png)

1. Create a symbolic link to ensure compatibility with some hardcoded entries by some programs using following command (run cmd.exe as admin):

```batch
mklink /d C:\Users\badname C:\Users\goodname
```

1. Now reboot the system and log in with the new username.
   * You can re-connect to Microsoft account now :)