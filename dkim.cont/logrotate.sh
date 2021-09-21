test -f "${0%/*}"/logrotate-pre.sh && . "${0%/*}"/logrotate-pre.sh

cd "${0%/*}"/data/logs
DATE="$(date -u +'%Y%m%d-%H%M%S')"
mv mail.log mail.log.$DATE

docker exec dkim start-stop-daemon --stop --signal HUP --pidfile /var/run/syslog.pid

gzip mail.log.$DATE
