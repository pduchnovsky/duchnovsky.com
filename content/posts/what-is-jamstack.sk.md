+++
categories = []
date = 2020-12-03T09:27:33
description = "JAMstack je moderná architektúra vývoja webu založená na klientskom JavaScript, API a obsahu napísanom vo formáte Markup. Generátory statických stránok úzko súvisia s architektúrou JAMstack, ktorá je sama o sebe iba skratkou. Prečo úzko súvisia ? Pretože bez nich by nebolo možné konkurovať dynamickému CMS."
externalLink = ""
images = ["/images/Mknql70lm3.png"]
series = []
slug = "co-je-jamstack"
tags = ["jamstack", "netlify", "hugo"]
title = "Čo je JAMstack ?"

+++
{{< notice info >}}
JAMstack je moderná architektúra vývoja webu založená na klientskom **J**avaScript, **A**PI a obsahu napísanom vo formáte **M**arkup. Generátory statických stránok úzko súvisia s architektúrou JAMstack, ktorá je sama o sebe iba skratkou. Prečo úzko súvisia ? Pretože bez nich by nebolo možné konkurovať dynamickému CMS.
{{< /notice >}}

![><](/images/F09IGjZjtp.png)

##### JavaScript

O dynamické funkcie sa stará JavaScript. Predstavte si, že chcem na svojej stránke kontaktný formulár. Ako ho implementujem len so statickými stránkami ? Neexistoval by spôsob, pretože statická stránka je statická stránka.

##### APIs

Operácie na strane servera sa abstrahujú do API a pristupuje sa k nim cez HTTPS pomocou JavaScriptu.

##### Markup

Webové stránky sa poskytujú ako statické súbory HTML. Môžu byť generované zo zdrojových súborov, ako je napríklad Markdown, pomocou statického generátora stránok.

{{< notice info >}}
Generátory statických stránok sa nepoužívajú samotné, ale skôr ako súčasť celého JAMstacku.
{{< /notice >}}

###### Static Site Generators

Generátory statických stránok nie sú novým nápadom, ale väčšina spoločností poskytujúcich webhosting nasadzuje nové webové stránky pomocou WordPressu atď., kde je obsah stránok/článkov uložený na serveri v databáze. Generátory statických stránok na druhej strane idú smerom k vopred generovaným statickým stránkam a potom ich poskytujú používateľom priamo prostredníctvom siete CDN.

Pripomeňme si, ako fungujú „tradičné“ najbežnejšie CMS na trhu: ak navštívite stránku, [URI](https://en.wikipedia.org/wiki/Uniform_Resource_Identifier) najskôr stiahne obsah tejto stránky z databázy na strane servera, potom príslušnú šablónu a až potom sa stránka naskladá a zobrazí v prehliadači. Nezáleží na tom, či používate MySQL ako databázu na strane servera a PHP ako jazyk, ktorý tieto stránky vytvára, alebo MongoDB s Node a stránky komponujete pomocou JavaScriptu. Toto je zásada - obsah sa nachádza v databáze a web ešte v skutočnosti neexistuje - vytvára sa priebežne až po prijatí žiadosti o stránku od používateľa.

Na druhej strane, statické generátory stránok (SSG) fungujú odlišne: ak požadujete stránku, stránka vo formáte html je už na strane servera pripravená na takmer okamžité zobrazovanie, všetky údaje na stránke boli pripravené vopred a poskytuje sa rovnakým spôsobom všetkým, ktorí navštívia vašu stránku. Teraz sa ponoríme trochu hlbšie. Celý váš obsah je zapísaný do súborov .md (Markdown) a tento obsah je potom vložený do súborov tém (html šablón) podľa vášho výberu podľa súboru pravidiel, všetko závisí od vybranej platformy statického generátora webových stránok, kde spustíte proces zostavovania, ktorý to urobí za vás, výsledkom bude statická stránka HTML s obsahom z príslušného súboru .md a vzhľadom podľa zvolenej šablóny. Vývoj s architektúrou JAMstack prebieha väčšinou lokálne, existujú však 'bezhlavé' systémy CMS, ktoré fungujú s väčšinou SSG (viac nižšie). Proces budovania môžete spustiť lokálne a iba skopírovať súbory html na svoj hostiteľský server alebo celý proces presunúť na stranu poskytovateľa hostiteľského servera (ak to podporujú), aby ste dokončili proces nasadenia, ktorý vaše súbory html umiestni na CDN podľa vášho výberu.

{{< notice info >}}
Je to ako vytvorenie fotokópie listu namiesto písania nového zakaždým, keď si ho niekto chce prečítať.
{{< /notice >}}

##### Aké sú výhody ?

Pretože obsah JAMstack sa generuje počas 'buildu' a poskytuje sa pomocou CDN, výhodou je **vyšší výkon**.

Pretože sa nemusíte obávať zraniteľnosti servera / databázy, je tiež výhodou **vyššia bezpečnosť**.

Hosting statických súborov je **veľmi lacný alebo dokonca zadarmo**..

Z pohľadu **vývojárov** je to **lepší zážitok**, môžete sa sústrediť na klientske rozhranie bez toho, aby ste sa starali o architektúru na pozadí. To tiež prináša **rýchlejší vývoj**.

V neposlednom rade je to **škálovateľné**, CDN sa stará o kompenzáciu dopytu používateľov :)

##### Pracovný postup

![><](/images/bVGg2diSHW.png)

Pracovný postup JAMstack je dosť jednoduchý, ako príklad si môžeme pozrieť tento web a zverejnenie nového príspevku do blogu.

1. Obsah tvorím pomocou markdownových súborov, tieto súbory je možné zapisovať ručne alebo pomocou "bezhlavého" CMS ako napr. [forestry.io](https://forestry.io/) alebo [Netlify CMS](https://www.netlifycms.org/) a mnoho ďalších.

   ![](/images/qwak29Af1Y.png)
2. Keď je obsah pripravený, jednoducho vykonám zmeny pomocou gitu v mojom úložisku, ku ktorému je pripojený [Netlify](https://www.netlify.com/) pre automatizované nasadenie. [Netlify](https://www.netlify.com/) potom začne build pomocou [Hugo](https://gohugo.io/) statického generátora stránok, toto zostavenie mojej stránky trvá priemerne 30 sekúnd, pretože Hugo je extrémne rýchly;)

   ![](/images/4AaWGM08OD.png)
3. Po dokončení zostavenia Netlify zverejní zmeny vo svojom CDN a zneplatní vyrovnávaciu pamäť.

Zmeny sú aktívne od začiatku do konca do jednej minúty .. :)

Ako poznámka pod čiarou, existujú služby, ktoré kombinujú všetky vyššie uvedené vlastnosti a výhody, jednou z nich je [stackbit](https://www.stackbit.com/), vyskúšajte si to !