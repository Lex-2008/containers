#!/bin/sh

cd "${0%/*}"
docker run --rm -i -v $PWD/data:/data -v $PWD/../bind.cont/data/key.conf:/key.conf --link bind:bind --name=dehydrated dehydrated git pull
docker run --rm -i -v $PWD/data:/data -v $PWD/../bind.cont/data/key.conf:/key.conf --link bind:bind --name=dehydrated dehydrated ./dehydrated -c
test -f data/deploy_cert || exit 0
cp data/certs/shpakovsky.ru/fullchain.pem data/certs/shpakovsky.ru/privkey.pem ../nginx.cont/data/cert/
sh ../nginx.cont/reload.sh
rm data/deploy_cert
