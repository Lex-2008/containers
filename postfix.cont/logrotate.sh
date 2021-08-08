test -f "${0%/*}"/logrotate-pre.sh && . "${0%/*}"/logrotate-pre.sh

docker exec postfix postfix -c /data/conf logrotate

test -f "${0%/*}"/logrotate-post.sh && . "${0%/*}"/logrotate-post.sh
