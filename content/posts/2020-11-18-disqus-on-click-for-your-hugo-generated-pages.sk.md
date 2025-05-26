+++
categories = []
date = 2020-11-18T21:09:02
description = "Viem, viem .. to už niektoré témy ponúkajú, ale existuje veľa takých, ktoré nie. Mnoho zastaraných sprievodcov nefunguje a dokonca som mal problémy s hľadaním správneho riešenia."
externalLink = ""
images = ["images/02lucMSbWk.png"]
series = []
slug = "disqus-po-kliknuti-pre-huga"
tags = ["hugo", "disqus"]
title = "Disqus 'po kliknutí' pre vaše stránky generované Hugom"

+++

Viem, viem .. to už niektoré témy ponúkajú, ale existuje veľa takých, ktoré nie. Mnoho zastaraných sprievodcov nefunguje a dokonca som mal problémy s hľadaním správneho riešenia.

### V prvom rade

Toto sú premenné, ktoré musia byť v konfiguračnom súbore

```md
disqusShortname = "yourdiscussshortname"
[params]
disqusOnClick = true
```

Súvisiace CSS pre styling tlačidla

```css
button {
  color: white !important;
  background-color: #1565c0;
  border: none;
  border-radius: 5px;
  padding: 10px 20px;
  margin: 6px 4px;
  font-size: 1.6rem;
  transition-duration: 0.4s;
  cursor: pointer;
}

button:hover {
  background-color: #42a5f5;
}
```

### Partial disqus

Potom začneme s tým, ako by ste na svoju stránku príspevkov mohli zahrnúť disqus komentáre (ak ešte nie sú zahrnuté v téme).

Mali by ste nájsť html súbor svojej témy pre jednotlivé stránky a na konci sekcie článku (alebo ekvivalent), umiestnili by ste toto:

`{{ partial "posts/disqus.html" . }}`

Týmto zaistíte zahrnutie súboru, ktorý vytvoríme (alebo upravíme)

Tento súbor by mal byť buď tu, ak chceme úplne prepísať súbor témy (relatívne k vášmu koreňovému adresáru webu):

`themes/<themename>/layouts/partials/posts/disqus.html`

Alebo ak sa nechcete dotknúť súborov témy, potom tu (vo vzťahu k vášmu koreňovému adresáru webu):

`layouts/partials/posts/disqus.html`

A nakoniec je to obsah `disqus.html`, ktorý umožňuje použitie **disqusOnClick**

```html
<!-- Adapted/developed by pduchnovsky, https://duchnovsky.com/2020/11/disqus-on-click-for-hugo/ -->
{{- if and (not (eq (.Site.Config.Services.Disqus.Shortname | default "") ""))
(eq (.Params.disableComments | default false) false) -}} {{- if
.Site.Params.disqusOnClick -}} {{- $pc := .Site.Config.Privacy.Disqus -}} {{- if
not $pc.Disable -}} {{- if .Site.Config.Services.Disqus.Shortname -}}
<section id="disqus" style="text-align: center">
  <button
    class="disqus-comment-count"
    data-disqus-identifier="{{ .File.UniqueID }}"
    id="show-comments"
    onclick="disqus();return false;"
  >
    Comments
  </button>
  <div id="disqus_thread"></div>
  <script>
    window.onload = function () {
      if (["localhost", "127.0.0.1"].indexOf(window.location.hostname) != -1) {
        document.getElementById("disqus_thread").innerHTML =
          "Disqus comments not available when the website is previewed locally.";
        document.getElementById("show-comments").style.display = "none";
        return;
      }
    };

    var disqus_loaded = false;
    var disqus_config = function () {
      this.page.identifier = "{{ .File.UniqueID }}";
      this.page.title = "{{ .Title }}";
      this.page.url = "{{ .Permalink | html }}";
    };
    function disqus() {
      if (!disqus_loaded) {
        disqus_loaded = true;

        var e = document.createElement("script");
        e.type = "text/javascript";
        e.async = true;
        e.src =
          "//{{ .Site.Config.Services.Disqus.Shortname }}.disqus.com/embed.js";
        (
          document.getElementsByTagName("head")[0] ||
          document.getElementsByTagName("body")[0]
        ).appendChild(e);

        document.getElementById("show-comments").style.display = "none";
      }
    }

    var hash = window.location.hash.substr(1);
    if (hash.length > 8) {
      if (hash.substring(0, 8) == "comment-") {
        disqus();
      }
    }

    if (
      /bot|google|baidu|bing|msn|duckduckgo|slurp|yandex/i.test(
        navigator.userAgent
      )
    ) {
      disqus();
    }
  </script>
  <script
    id="dsq-count-scr"
    src="https://{{ .Site.Config.Services.Disqus.Shortname }}.disqus.com/count.js"
    async
  ></script>
  <noscript>
    Please enable JavaScript to view the
    <a href="https://disqus.com/?ref_noscript"> comments powered by Disqus. </a>
  </noscript>
  <a href="https://disqus.com" class="dsq-brlink">
    powered by <span class="logo-disqus">Disqus</span>
  </a>
</section>
{{- end -}} {{- end -}} {{- else -}} {{ template "_internal/disqus.html" . }}
{{- end -}} {{- end -}}
```

Táto časť kódu zaisťuje, že vaše komentáre disqus sa načítajú iba po stlačení tlačidla, ak nastavíte premennú disqusOnClick, ak nie je definovaná, načíta sa predvolený súbor huga `_internal/disqus.html`

Zaisťuje tiež, že sa disqus nebude načítať, keď testujete lokálne, a tiež zobrazí množstvo komentárov vo vašom vlákne disqus.
