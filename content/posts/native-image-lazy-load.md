+++
categories = ["snippets", "guides"]
date = 2020-11-11T23:00:00Z
description = "I was looking around for an easy way to what I was trying to achieve.. but didn't find it, so I decided to create a pipe"
externalLink = ""
images = ["/images/ue45Hl47oy.png"]
slug = "native-image-lazy-load"
tags = ["hugo"]
title = "Native image 'lazy' loading, fingerprinting, responsiveness"

+++

I was looking around for an easy way to what I was trying to achieve.. but didn't find it, so I decided to create a pipe (that's what they are called, right ? :D) on my own.

I was basically trying to achieve these things:

- Adding html image lazy load which is now supported by majority of browsers
- Adding image width/height so in case of loading my page won't jump like crazy
- Generating an image "fingerprint" for so-called cache busting
- Generating different image sizes for responsiveness

^ these should improve pagespeed rating quite a bit in some cases.

Anyway, this is a piece of code that you should put in `layouts/_default/_markup/render-image.html`, this works not only for images in the `assets` folder but also for images located in the `static` or `content` directories, fingerprinting and generating different image sizes will only work for images in the `assets` folder though.

```go
<!-- layouts/_default/_markup/render-image.html -->
<!-- Developed/Adapted by pduchnovsky, https://duchnovsky.com/2020/11/native-image-lazy-load/ -->

{{ $img := "" }}{{ $thumb := "" }}{{ $srcset := slice }}
{{ $src := ( .Destination | safeURL ) }}
{{ $alt := .PlainText }}
{{ $caption := .Title | safeHTML }}
{{ $imgPath := add "/content" $src }}
{{ if fileExists $imgPath }}
    {{ $img = imageConfig $imgPath }}
{{ else }}
    {{ $imgPath = add "/static" $src }}
    {{ if fileExists $imgPath }}
        {{ $img = imageConfig $imgPath }}
    {{ end }}
{{ end }}
{{ if not $img }}
    {{ with resources.Get .Destination }}
        {{ $src = (. | fingerprint).RelPermalink }}
        {{ $img = . }}
        {{ $sizes := slice 500 800 1200 }}
        {{ range $sizes }}
            {{ if and (le (mul . 1) $img.Width) }}
            {{ $thumb = $img.Resize (printf "%dx CatmullRom" .) }}
            {{ $srcset = $srcset | append (printf ("%s %dw") $thumb.RelPermalink . ) }}
            {{ end }}
        {{ end }}
    {{ end }}
{{ end }}

{{ if $img }}
    <figure>
        <img
        src="{{ $src }}"
        alt="{{ if $alt }}{{ $alt }}{{ else if $caption }}{{ $caption | markdownify | plainify }}{{ else }}&nbsp;{{ end }}"
        loading="lazy"
        {{ if gt (len $srcset) 0 }}
            srcset="{{ (delimit $srcset ", " | safeHTMLAttr) }}"
            {{ if in .Text "_gallery" }}
                sizes="25vw"
            {{ else }}
                sizes="100vw"
            {{end}}
            width="{{ $thumb.Width }}"
            height="{{ $thumb.Height }}"
        {{ else }}
            width="{{ $img.Width }}"
            height="{{ $img.Height }}"
        {{ end }}
        />
    {{ with $caption }}
        <figcaption>{{ . | markdownify }}</figcaption>
    {{ end }}
    </figure>
{{ end }}
```

Note: It is necessary to use css `img {height: auto;max-width: 100%}` so the images are properly automatically sized on your page.
