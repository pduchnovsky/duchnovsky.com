+++
categories = ["skripty"]
date = 2020-11-09T23:00:00Z
description = "Ak chcete, aby sa vaša stránka načítavala rýchlo a chcete získať pekné skóre na stránkach pagespeed, lighthouse alebo všeobecne.. musíte optimalizovať veľkosť svojich obrázkov."
externalLink = ""
images = ["/images/mnolwuduqt.png"]
slug = "optimalizacia-webovych-obrazkov"
tags = ["optimalizacia", "web", "obrazky", "bash"]
title = "Optimalizácia obrázkov pre webové stránky skriptom"

+++

Ak chcete, aby sa vaša stránka načítavala rýchlo a chcete získať pekné skóre na stránkach pagespeed, lighthouse alebo všeobecne.. musíte optimalizovať veľkosť svojich obrázkov.

Našiel som jednoduchý skript, ktorý som ešte viac optimalizoval aby mi túto namáhavú úlohu zautomatizoval a rozhodol som sa ho tu zdieľať, ak by mal niekto záujem :)

Ak ho však chcete použiť, najskôr nainštalujte nasledujúce balíčky

`sudo apt-get install optipng advancecomp pngcrush jpegoptim`

Potom jednoducho použite tento skript vo svojom zdrojovom adresári webu, môžete nakonfigurovať viac adresárov ako výnimku, v mojom prípade pretože používam Hugo, sú to adresáre ako **themes** a **\_resources**, kde nechcem optimalizovať obrázky.

```bash
#!/bin/bash
# Script adapted by pduchnovsky
# https://duchnovsky.com/2020/11/images-optimization-for-web/

# Add list of folder names to ignore array here, separated by space
ignore=("./themes/*" "./resources/*" "./assets/*")

# Array of png optimizers with their arguments
optimizers=(
    "optipng -nb -nc"
    "advpng -z4"
    "pngcrush -rem gAMA -rem alla -rem cHRM -rem iCCP -rem sRGB -rem time -ow"
)

# File to check/create in order to stop processing already processed files since last run.
file=optimg.flag

# Only use -newer option if file already exists
if [ -f "$file" ]; then
    option="-newer $file"
fi

# Prepare arguments from ignore list
ignorearg=()
for ignored in "${ignore[@]}"; do
  ignorearg+="-not -path "*${ignored}" "
done

# Optimize png images with optimizers and their settings
for optimizer in "${optimizers[@]}"
do
    find . -type f $option -iname "*.png" $ignorearg -exec $optimizer  {} \;
done

# Optimize using jpegoptim
find . -type f $option -iregex .*\.jpe?g$ $ignorearg\
-exec jpegoptim -m85 --all-progressive -f --strip-all {} \;

# touch file so it updates last run-time
touch $file
```
