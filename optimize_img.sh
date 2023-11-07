#!/bin/bash
# Script adapted by pduchnovsky
# https://pduchnovsky.com/2020/11/images-optimization-for-web/

# Add list of folder names to ignore array here, separated by space
ignore=("./themes/*" "./resources/*" "./assets/*" "./public/*")

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
