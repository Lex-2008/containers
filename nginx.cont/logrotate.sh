test -f "${0%/*}"/logrotate-pre.sh && . "${0%/*}"/logrotate-pre.sh

cd "${0%/*}"/data/logs
DATE="$(date -u +'%Y%m%d-%H%M%S')"
mkdir logs-$DATE
mv `find -maxdepth 1 -type f` logs-$DATE

docker exec nginx nginx -s reopen -c /data/conf/nginx.conf

gzip logs-$DATE/*.log
