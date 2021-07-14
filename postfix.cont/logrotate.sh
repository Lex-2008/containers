test -f "${0%/*}"/logrotate-pre.sh && . "${0%/*}"/logrotate-pre.sh

docker exec -it postfix postfix -c /data/conf logrotate
