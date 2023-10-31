+++
categories = ["navody"]
date = 2020-11-04T23:00:00Z
description = "Naposledy som skúsil generátory statických stránok dosť dávno.. pred niekoľkými rokmi, bol to vtedy strašný zážitok, ak mám byť úprimný .. tie časy sú už ale dávno preč."
externalLink = ""
images = ["/images/g3v56GPzfe.png"]
slug = "rychly-lahky-generator-stranok"
tags = ["hexo"]
title = "Rýchle a ľahké SSG s hostingom s custom doménou"

+++
*Aktualizované: Hexo už nepoužívam ako svoj statický generátor stránok, medzitým som prešiel na Hugo, ale tento sprievodca je stále relevantný.*

... a to všetko .. **zadarmo**? **Áno** ! (Okrem samotnej domény :))

Ako bonus je to celkom ľahké a hlavne, ak ste trochu ako ja, je to aj celkom **zábavné**.

Poďme teda na to, moje nastavenie je už hotové, takže táto príručka sa robí retrospektívne. Takto by malo byť nastavenie najmenej bolestivé.

Naposledy som skúsil generátory statických stránok dosť dávno.. pred niekoľkými rokmi, bol to vtedy strašný zážitok, ak mám byť úprimný .. tie časy sú už ale dávno preč.

Hľadal som ľahký, rýchly a ľahko pochopiteľný SSG, rozhodol som sa pre [Hexo](https://hexo.io)

Táto príručka je napísaná spôsobom, ktorý od vás očakáva, že budete oboznámení aspoň so základmi git, npm a linuxom všeobecne.

#### Predpoklady:

* Bezplatné účty na [GitHub](https://github.com) aj [Netlify](https://www.netlify.com) (a áno, môžete sa zaregistrovať do služby Netlify pomocou svojho účtu GitHub :)
* Systém Linux alebo Windows 10 WSL / 2
* Nainštalované [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git), [nodejs](https://nodejs.org/en/download) + [npm](https://www.npmjs.com/get-npm)

### Poďme začať !

1. Vytvorte nové repo na GitHube pomocou [tohto odkazu](https://github.com/new)
    * Môžete si zvoliť súkromné úložisko

2. Teraz poďme nainštalovať a nakonfigurovať hexo.

   ```bash
   # Install prerequisite packages
   sudo apt install libtool automake autoconf nasm
   # Install hexo npm package globally (-g)
   sudo npm install -g hexo-cli
   ```

   Teraz vytvorme nový adresár a inicializujme ho
   ```bash
   mkdir -p your/repo/dir
   hexo init your/repo/dir
   cd your/repo/dir
   # Install hexo packages
   npm install
   # Install additional hexo plugins, --save ensures that these plugins are
   # saved to package.json file, so netlify can install them too !
   npm install --save hexo-all-minifier
   npm install --save hexo-asset-link
   ```

	Ukážem vám, ako vyzerá základná adresárová štruktúra a ktoré konfiguračné súbory existujú:
    ```bash
    pd@pd:~/repos/hexo-web$ tree . -L 3
    .
    ├── README.md
    ├── _config.yml  # <= "Hlavný" hexo config
    ├── content
    │   └── contact.md
    ├── scaffolds
    │   ├── draft.md
    │   ├── page.md
    │   └── post.md
    ├── source
    │   ├── _posts
    │   └── images
    └── themes
        └── minima
            ├── LICENSE
            ├── README.md
            ├── _config.yml   # <= Hexo config "témy"
            ├── layout
            └── source
    ```
3. Teraz je čas upraviť súbor _config umiestnený vo vašom novo inicializovanom adresári, nakonfigurovať základné informácie, ako napríklad **adresa URL, nadpis, popis, kľúčové slová** atď.

   potom pridajte tieto riadky na koniec, aby vyššie nainštalované  doplnky mohli fungovať.

   ```yaml
   # hexo-all-minifier
   all_minifier: true
   image_minifier:
     optimizationLevel: 2
     progressive: true
   ```
4. Voliteľne môžete nainštalovať vlastnú tému z rôznych dostupných [tu](https://hexo.io/themes) alebo rovno pokračovať v nastavovaní súboru `_config.yml` predvolenej témy tu: `themes/landscape/_config.yml`, kde je potrebné upraviť aj niektoré polia, ako napríklad **title, owner, info, description** atď. (v závislosti od témy).
5. Nové príspevky pridáte vykonaním `hexo new post <názov príspevku>` a vygeneruje sa nový príspevok v adresári `source/_posts`, kde ich môžete upravovať. Spočiatku sa tam nachádza súbor `hello-world.md`. aby ste sa s tým mohli oboznámiť.
6. Po nastavení hlavných konfiguračných aj konfiguračných súborov hexa a taktiež témy na základe vašich preferencií môžete svoju stránku otestovať lokálne spustením hexo miestneho servera.

   ```bash
   hexo server
   ```

   Keď budete so svojou stránkou barebone spokojní, môžeme pokračovať k časti deploymentu.


### Deployment

1. Najskôr pridajte svoj [kľúč ssh](https://www.ssh.com/ssh/keygen) [do svojho účtu github tu](https://github.com/settings/keys)
2. Z vášho koreňového adresára hexo (alebo takzvaného adresára projektu git) budete vykonávať počiatočné (a následné) deploymenty do repa GitHub týmto spôsobom:

   ```bash
   # Choďte do svojho adresára, kde ste inicializovali hexo
   cd your/repo/dir
   # Inicializujte git
   git init
   # teraz sa pripojte k vzdialenému úložisku git
   git remote add origin git@github.com:username/repo_name.git
   # Pridajte všetky zmeny
   git add .
   # Potvrďte všetky zmeny
   git commit -a
   # Odošlite svoje zmeny
   git push
   ```

   Pre ľahšiu správu, som vytvoril funkciu ako 'alias', môžete tento kúsok kódu pridať do svojho `.bashrc` alebo `.bash_aliases` do domovského adresára (~/).

   ```bash
   push () {
       read -p "Popis zmien:" desc
       git add . && git add . && git commit -a --allow-empty-message -m "$desc" && git push
   }
   # 'git add .' je tam dvakrát, takže tiež zachytáva premenované súbory
   ```

   Potom vykonajte `exec $SHELL`, aby sa načítali zmeny, odteraz bude príkaz `push` pracovať a bude vykonávať automaticky kroky vyššie naraz so správou alebo bez správy (pre repo vo vašom aktuálnom adresári).
3. Po zverejnení kódu v službe github môžeme nastaviť stránku netlify :) prejdite na [app.netlify.com](https://app.netlify.com) a kliknite na '**new site from git**' a postupujte podľa pokynov na obrazovke, netlify zistí, že používate hexo a pripraví za vás príkazy / adresár repa, takže môžete pokračovať v 'deploy site'.

4. V časti **site settings** nastavte nasledujúce možnosti na netlify, aby ste optimalizovali build a prostredie:

	> **General** -> Site details -> Change site name -> Vyberte si vlastný názov;)
    >
    > **Build & deploy** -> Post Processing -> Asset Optimization -> Edit settings -> Zvoľte si len **Bundle CSS**.
    >
    > * Ostatné možnosti nie sú také účinné ako doplnok, ktorý sme nainštalovali pre hexo (hexo-all-minifier)
    >
    > **Domain Management**: Voliteľne si môžete nastaviť vlastnú doménu a určite nastavte **https** certifikát, ktorý je samozrejme vďaka ÚŽASNÉMU [Let's encrypt](https://letsencrypt.org) zadarmo!
5. Teraz.. zakaždým, keď „tlačíte“ zmeny do vášho repa, program netlify automaticky **magicky** vytvorí stránku pomocou hexa a zverejní ju.
* Let me note that using netlify is in in my opinion currently better choice than github pages, you may use github pages if you set up deployment to public repo (you can create new repo where hexo will deploy using [hexo-deployer-git](https://github.com/hexojs/hexo-deployer-git), but it gets little bit more complicated)..
   * To je veľká výhoda Netlify v porovnaní s GitHub Pages, okrem iného .. ako napríklad, že github posiela iba v HTML hlavičke len  10 minútový Cache-Control, čo je ďaleko od ideálu..

#### Voliteľné veci

Ja osobne používam nasledujúce dva ďalšie pluginy:

    npm install --save hexo-generator-sitemap
    npm install --save hexo-helper-obfuscate



1. **hexo-generator-sitemap**
   * Najjednoduchším spôsobom je použitie funkcie vkladania kódu Netlify.. v nastaveniach stránky netlify vyberte **Build & Deploy** -> **Post processing** -> **Snippet injection** -> **Add snippet**
     * Vyberte **Insert before head**
     * Pomenujte skript, ako chcete
     	* A potom vložte nasledujúci kód:

       ```html
       <% if (config.sitemap.rel) { %>
       <link rel="sitemap" href="<%-config.url + config.sitemap.path %>" />
       <% } %>
       ```

     Takto zaistíte, že po deploymente bude váš web poskytovať kanonické odkazy (pre lepšie SEO), ako aj odkaz na vygenerovaný súbor Sitemap.
	*K dispozícii je tiež možnosť upraviť súbor `layout.ejs` vašej témy a umiestniť kód pred koniec hlavičky.*

     * Ale ešte sme neskončili.. toto musí byť vložené do vášho **hexo configu:**

     ```yaml
     # hexo-generator-sitemap
     sitemap:
       path: /sitemap.xml
       template: ./sitemap_template.xml
       rel: true
       tags: true
       categories: true
     ```
	* Vytvorte tiež tento súbor `sitemap_template.xml` v koreňovom adresári projektu:

     ```xml
     <?xml version="1.0" encoding="UTF-8"?>
     <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
       {% for post in posts %}
       <url>
         <loc>{{ post.permalink | uriencode }}</loc>
         {% if post.updated %}
         <lastmod>{{ post.updated | formatDate }}</lastmod>
         {% elif post.date %}
         <lastmod>{{ post.date | formatDate }}</lastmod>
         {% endif %}
       </url>
       {% endfor %}
     
       <url>
         <loc>{{ config.url | uriencode }}</loc>
         <lastmod>{{ sNow | formatDate }}</lastmod>
         <changefreq>daily</changefreq>
         <priority>1.0</priority>
       </url>
     
       {% for tag in tags %}
       <url>
         <loc>{{ tag.permalink | uriencode }}</loc>
         <lastmod>{{ sNow | formatDate }}</lastmod>
         <changefreq>daily</changefreq>
         <priority>0.6</priority>
       </url>
       {% endfor %}
     
       {% for cat in categories %}
       <url>
         <loc>{{ cat.permalink | uriencode }}</loc>
         <lastmod>{{ sNow | formatDate }}</lastmod>
         <changefreq>daily</changefreq>
         <priority>0.6</priority>
       </url>
       {% endfor %}
     </urlset>
     ```
   * Môžete tiež povoliť voliteľný doplnok „Submit Sitemap“ od autora cdeleeuwe v **Plugins** sekcii Netlify, ktorý po každom builde automaticky odosiela náš súbor Sitemap do služieb Google, Bing a Yandex.
2. **hexo-helper-obfuscate**
     * Pokiaľ ide o doplnok hexo **obfuscation**, môžete tento html kód použiť vo svojich príspevkoch alebo súboroch s motívmi na 'zahmlievanie' e-mailových adries.
	To by malo poskytovať aspoň minimálnu ochranu.
    ```html
    <a href="mailto:<%- obfuscate(email@address.here) %>" target="_blank">email me</a>
    ```

	Osobne som to vložil do svojeho menu (súbor „header.ejs“ mojej témy) a zabezpečil, aby to bralo e-mailovú adresu z novo definovanej premennej „email“, ktorú som vložil do svojej konfigurácie témy.
	```html
	<% if (theme.email) { %>
	<a href="mailto:<%- obfuscate(theme.email) %>" target="_blank" class="ml">email</a>
	<% } %>
	```