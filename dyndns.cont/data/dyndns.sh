#!/bin/sh

echo "HTTP/1.0 200 OK"
echo

# ### useful env vars ###
# export HTTP_X_REAL_IP='2a02:440:0:13::559'
# export HTTP_X_REAL_USER='test'
# export PATH_INFO='/path'
# export QUERY_STRING='query'

zone="dyn.shpakovsky.ru"
user="$HTTP_X_REAL_USER"
host="$user.$zone"
ip="${QUERY_STRING:-$HTTP_X_REAL_IP}"

# echo "setting [$ip] for [$user]"

expr "$ip" : '.*\.' >/dev/null && atype=A
expr "$ip" : '.*:' >/dev/null && atype=AAAA

test -z "$atype" && exit 1

grep -qsF "$ip" "/tmp/dyndns-$user-$atype" && exit 0

echo "server bind 5353
zone $zone
del $host $atype
add $host 1 $atype $ip
send" | nsupdate -k /key.conf

echo "$ip" >"/tmp/dyndns-$user-$atype"
