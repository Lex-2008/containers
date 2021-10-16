#!/bin/sh

echo "HTTP/1.0 200 OK"
echo

# ### useful env vars ###
# export HTTP_X_REAL_IP='2a02:440:0:13::559'
# export HTTP_X_REAL_USER='test'
# export PATH_INFO='/path'
# export QUERY_STRING='query'

zone="dyn.shpakovsky.ru"
host="$HTTP_X_REAL_USER.$zone"

expr "$HTTP_X_REAL_IP" : '.*\.' >/dev/null && atype=A
expr "$HTTP_X_REAL_IP" : '.*:' >/dev/null && atype=AAAA

test -z "$atype" && exit 1

echo "server bind
zone $zone
del $host $atype
add $host 1 $atype $HTTP_X_REAL_IP
send" | nsupdate -k /key.conf
