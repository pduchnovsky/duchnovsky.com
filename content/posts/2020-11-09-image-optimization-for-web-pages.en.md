+++
categories = ["scripts"]
date = 2020-11-09T23:00:00
description = "If you want your page to load fast and you want to get some nice score on pagespeed or lighthouse or in general.. you must optimize the size of your images."
externalLink = ""
images = ["images/mnolwuduqt.png"]
slug = "images-optimization-for-web"
tags = ["optimization", "web", "images", "bash"]
title = "Image optimization for web pages with script"

+++

If you want your page to load fast and you want to get some nice score on pagespeed or lighthouse or in general.. you must optimize the size of your images.

I found simple script that I actually optimized even more in order to automate this tedious task for me, might as well share it here, if anybody is interested :)

However, in order to use it, first install following packages

`sudo apt-get install optipng advancecomp pngcrush jpegoptim`

Then simply use this script in your web source directory, you might configure multiple directories as an exception, in my case since I use Hugo, it's like **themes** and **\_resources** directories where I do not want to optimize images.

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
