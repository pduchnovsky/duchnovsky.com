# duchnovsky.com

Initialize submodule(s)

    git submodule update --init --recursive

Install Hugo

    brew install hugo

Start Server

    (sleep 1 && open https://localhost:3560) & hugo serve -p 3560 --tlsAuto --buildFuture
