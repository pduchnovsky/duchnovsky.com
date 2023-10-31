+++
categories = ["navody"]
date = 2020-10-15T23:00:00Z
description = "Existuje niekoľko prípadov, keď by ste chceli premenovať niekoho užívateľský účet a priečinok s profilom a ja vám vysvetlím, ako to urobiť správne."
externalLink = ""
images = ["/images/ehO75Qfj6i.png"]
slug = "rename-user-account"
tags = ["windows 10", "cmd", "regedit"]
title = "Premenovanie účtu systému Windows a jeho priečinka"

+++
Existuje niekoľko prípadov, keď by ste chceli premenovať niekoho užívateľský účet a priečinok s profilom a ja vám vysvetlím, ako to urobiť správne.

Najskôr začnime s...

#### Predpoklady

* Účet je lokálny/miestny
  * Musíte ho dočasne odpojiť od účtu Microsoft
  * Pre účty Azure / AD tento návod nefunguje
* Cieľový názov účtu neexistuje a nikdy neexistoval
* Máte prístup k inému účtu správcu na rovnakom počítači

Ak ste pripravení s predpokladmi..

### Začnime

V tomto scenári premenujme imaginárny účet _'badname'_ na _'goodname'_ pomocou iného účtu správcu _„správca“_.

1. Prihláste sa ako _správca_
2. Prejdite na **Ovládací panel > Používateľské účty > Spravovať iný účet > Vyberte _badname_ > Zmeniť meno**
3. Teraz premenujte účet na _goodname_
4. Premenujte priečinok **C:\\Users\\_badname_** na **C:\\Users\\_goodname_**
5. Vykonajte vyhľadávanie a výmenu v registri. Pre mňa to bolo najjednoduchšie pomocou nástroja ako [Advanced Regedit (win32)](https://sourceforge.net/projects/regedt33/)
   * Po otvorení programu stlačte Ctrl + H
   * Postupujte podľa nižšie uvedeného príkladu a definujte Štart a Koniec(end):
     ![screenshot](/images/RqBv1kATBR.png)
6. Vytvorte symbolický odkaz na zaistenie kompatibility s niektorými pevne zakódovanými položkami niektorých programov pomocou nasledujúceho príkazu (spustite cmd.exe ako administrátor):

```batch
mklink /d C:\Users\badname C:\Users\goodname
```

1. Teraz reštartujte systém a prihláste sa pomocou nového používateľského mena.
   * Teraz sa môžete znova pripojiť k účtu Microsoft :)