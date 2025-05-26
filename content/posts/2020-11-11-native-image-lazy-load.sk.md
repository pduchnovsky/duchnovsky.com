+++
categories = ["snippets", "navody"]
date = 2020-11-11T23:00:00
description = "Hľadal som okolo ľahkú cestu k tomu, čo som sa snažil dosiahnuť .. ale nenašiel som to, tak som sa rozhodol, že si sám vytvorím hugo 'pipeline'"
externalLink = ""
images = ["images/ue45Hl47oy.png"]
slug = "nativny-image-lazy-loading"
tags = ["hugo"]
title = "Natívne 'lenivé' načítanie, fingerprinting, responsiveness obrázkov"

+++

Hľadal som ľahkú cestu k tomu, čo som sa snažil dosiahnuť .. ale nenašiel som to, tak som sa rozhodol, že si sám vytvorím hugo 'pipeline' (tak sa im hovorí, či ? :D).

V podstate som sa snažil dosiahnuť tieto veci:

- Pridanie 'lenivého' načítania obrázka html, ktoré teraz podporuje väčšina prehliadačov
- Pridanie šírky / výšky obrázka, aby v prípade načítania stránky neskákali ako bláznivé
- Generovanie "odtlačku prsta" obrázka pre tzv. cache busting
- Generovanie rôznych veľkostí obrázkov pre responzívnost

^ tieto veci by taktiež mali v niektorých prípadoch trochu vylepšiť hodnotenie rýchlosti stránok.

Toto je každopádne kúsok kódu, ktorý by ste mali vložiť do `layouts/_default/_markup/render-image.html`, toto funguje okrem obrázkov v priečinku `assets` aj pre obrázky, ktoré sa nachádzajú v adresároch `static` alebo `content`, ale fingerprinting a generovanie rôznych veľkostí obrázkov bude fungovať len pre obrázky v `assets` priečinku.

```go
<!-- layouts/_default/_markup/render-image.html -->
<!-- Developed/Adapted by pduchnovsky, https://duchnovsky.com/2020/11/native-image-lazy-load/ -->

{{ $img := "" }}
{{ $thumb := "" }}
{{ $srcset := slice }}
{{ $src := .Destination | safeURL }}
{{ $alt := .PlainText }}
{{ $caption := .Title | safeHTML }}

{{ $defaultSizes := slice 480 768 1024 1280 1600 }}
{{ $isProcessedImage := false }}

{{ with resources.Get .Destination }}
  {{ $img = . }}
  {{ $src = (. | fingerprint).RelPermalink }}
  {{ $isProcessedImage = true }}

  {{ range $defaultSizes }}
    {{ if and (le . $img.Width) (gt $img.Width 0) }}
      {{ $thumb = $img.Resize (printf "%dx CatmullRom" .) }}
      {{ $srcset = $srcset | append (printf "%s %dw" $thumb.RelPermalink .) }}
    {{ else if and (gt . $img.Width) (gt $img.Width 0) }}
      {{ $thumb = $img.Resize (printf "%dx CatmullRom" $img.Width) }}
      {{ $srcset = $srcset | append (printf "%s %dw" $thumb.RelPermalink $img.Width) }}
    {{ end }}
  {{ end }}

  {{ if not $thumb }}
    {{ $thumb = $img }}
  {{ end }}
{{ end }}

<figure>
  <img
    src="{{ $src }}"
    alt="{{ if $alt }}{{ $alt }}{{ else if $caption }}{{ $caption | markdownify | plainify }}{{ else }}{{ "" }}{{ end }}"
    loading="lazy"
    {{ if $isProcessedImage }}
      {{ if gt (len $srcset) 0 }}
        srcset="{{ delimit $srcset ", " | safeHTMLAttr }}"
        sizes="{{ if in .Text "_gallery" }}25vw{{ else if in .Text "_half" }}50vw{{ else }}100vw{{ end }}"
        width="{{ $thumb.Width }}"
        height="{{ $thumb.Height }}"
      {{ else }}
        width="{{ $img.Width }}"
        height="{{ $img.Height }}"
      {{ end }}
    {{ end }}
  />
  {{ with $caption }}
    <figcaption>{{ . | markdownify }}</figcaption>
  {{ end }}
</figure>
```

Poznámka: Je potrebné použiť css `img {height: auto; max-width: 100%}`, aby sa vždy obrázky na vašej stránke správne automaticky naškálovali.
