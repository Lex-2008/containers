# TODO: curl logshow to static file

cd "${0%/*}"/data/logs
DATE="$(date -u +'%Y%m%d-%H%M%S')"
mkdir logs-$DATE
mv `find -maxdepth 1 -type f` logs-$DATE

docker exec -it nginx nginx -s reopen -c /data/conf/nginx.conf

gzip logs-$DATE/*.log
