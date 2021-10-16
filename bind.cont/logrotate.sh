test -f "${0%/*}"/logrotate-pre.sh && . "${0%/*}"/logrotate-pre.sh

cd "${0%/*}"/data/logs
DATE="$(date -u +'%Y%m%d-%H%M%S')"
mv mail.log mail.log.$DATE

"${0%/*}"/reload.sh

gzip mail.log.$DATE
