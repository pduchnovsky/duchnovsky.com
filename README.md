# pduchnovsky.com

Initialize submodule(s)

    git submodule update --init --recursive

Install Hugo & packages for optimize_img.sh script

    brew install hugo
    sudo apt-get -y install optipng advancecomp pngcrush jpegoptim

Optimize images

    chmod +x optimize_img.sh
    ./optimize_img.sh

Start Server

    hugo server
