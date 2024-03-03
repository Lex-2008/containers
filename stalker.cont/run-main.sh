#!/bin/sh

cd "${0%/*}"
OUTDIR="/containers/gemini.cont/data/hosts/stalker.shpakovsky.ru"
docker run --rm -v $PWD/data:/data -v $OUTDIR:/ext stalker /data/main.sh main >"$OUTDIR/log.txt" 2>&1
cd /containers/stalker.cont/data
tar czf data.tar.gz data
