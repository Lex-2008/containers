#!/bin/sh

cd "${0%/*}"
docker run --rm -v $PWD/data:/data -v /containers/gemini.cont/data/hosts/stalker.shpakovsky.ru:/ext stalker /data/main.sh main
