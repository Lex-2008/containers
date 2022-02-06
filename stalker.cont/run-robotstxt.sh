#!/bin/sh

cd "${0%/*}"
docker run --rm -v $PWD/data:/data stalker /data/main.sh robotstxt
