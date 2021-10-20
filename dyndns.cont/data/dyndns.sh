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

grep -qsF "$HTTP_X_REAL_IP" "/tmp/dyndns-$HTTP_X_REAL_USER-$atype" && exit 0

echo "server bind 5353
zone $zone
del $host $atype
add $host 1 $atype $HTTP_X_REAL_IP
send" | nsupdate -k /key.conf

echo "$HTTP_X_REAL_IP" >"/tmp/dyndns-$HTTP_X_REAL_USER-$atype"
