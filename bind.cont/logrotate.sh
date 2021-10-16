test -f "${0%/*}"/logrotate-pre.sh && . "${0%/*}"/logrotate-pre.sh

cd "${0%/*}"/data/logs
DATE="$(date -u +'%Y%m%d-%H%M%S')"
mv bind.log bind.log.$DATE

sh ../../reload.sh

gzip bind.log.$DATE
