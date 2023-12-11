+++
categories = ["guides"]
date = 2020-11-18T21:09:02Z
description = "I know, I know.. this is what some themes are offering already but there is plenty that don't.. many outdated guides are not working and even I had problems finding proper solution."
externalLink = ""
images = ["/images/02lucMSbWk.png"]
series = []
slug = "disqus-on-click-for-hugo"
tags = ["hugo", "disqus"]
title = "Disqus 'on-click' for your Hugo generated pages"

+++

I know, I know.. this is what some themes are offering already but there is plenty that don't.. many outdated guides are not working and even I had problems finding proper solution.

### First of all

These are variables that must be in your config file

```md
disqusShortname = "yourdiscussshortname"
[params]
disqusOnClick = true
```

Related CSS for styling of a button

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

Then we start with how you'd include the disqus comments (if not yet included in your theme) to your posts page.

You should find your theme's html file for single pages and near end of article section (or equivalent), you'd put this:

`{{ partial "posts/disqus.html" . }}`

This will ensure include of the file we're going to create (or edit)

This file should be either here, if we're going to overwrite theme file completely (relative to your web root directory):

`themes/<themename>/layouts/partials/posts/disqus.html`

Or if you don't want to touch theme's files, then here (relative to your web root directory):

`layouts/partials/posts/disqus.html`

And finally, this is the content of the `disqus.html` that enables use of **disqusOnClick**

```html
<!-- Adapted/developed by pduchnovsky, https://duchnovsky.com/2020/11/disqus-on-click-for-hugo/ -->
{{- if and (not (eq (.Site.DisqusShortname | default "") "")) (eq
(.Params.disableComments | default false) false) -}} {{- if
.Site.Params.disqusOnClick -}} {{- $pc := .Site.Config.Privacy.Disqus -}} {{- if
not $pc.Disable -}} {{- if .Site.DisqusShortname -}}
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
        e.src = "//{{ .Site.DisqusShortname }}.disqus.com/embed.js";
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
    src="https://{{ .Site.DisqusShortname }}.disqus.com/count.js"
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

This piece of code ensures that your disqus comments will load only when a button is pressed once you set up variable disqusOnClick, if it's not defined, it will load default hugo's `_internal/disqus.html` file.

It also ensures disqus won't load when you are testing locally and it will also show amount of comments in your disqus thread.
