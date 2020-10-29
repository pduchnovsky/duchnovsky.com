title: Rename Windows user account and its profile folder
tags:
  - guide
  - windows 10
  - windows 8
  - account
  - rename
  - mklink
thumbnail: /images/pasted-2.png
categories: []
date: 2020-10-29 17:56:00
---
There are few cases where you'd like to rename somebody's user account as well as profile folder and I will explain on how to do it properly.

First of all, let's start with..

##### Prerequisites

- The account is local
  - You have to temporarily disconnect it from Microsoft account
  - This is not easily possible for Azure/AD accounts
- The target account name does not exist and it never existed
- You have access to another admin account on the same machine

If you are ready with above..

##### Let's get started.

For this scenario let's rename imaginary account *'badname'* to *'goodname'*, with help of another admin account *'administrator'*.
1. Log in as *administrator*
2. Go to Control Panel > User Accounts > Manage another account > Choose *badname* > Change Name
3. Now rename the account to *goodname*
4. Rename folder C:\Users\\*badname* to C:\Users\\*goodname*
5. Do batch search and replace in the registry, I found it was the easiest using tool like [Advanced Regedit (win32)](https://sourceforge.net/projects/regedt33/)
  - Upon opening the program press Ctrl + H
  - Follow example below and define Start and End keys:
![](/images/pasted-4.png)
6. Now create a symbolic link to ensure compatibility with some hardcoded entries by some programs using following command (run cmd.exe as admin):
  ``` batch
  mklink /d C:\Users\badname C:\Users\goodname
  ```
7. Now reboot the system and log in with the new username.
	- You can re-connect to Microsoft account now.