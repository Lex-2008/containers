#!/bin/false # this file should be sourced, not run

# config
# $1 is filename/option/token
#    or filename?option
IFS='/?' read -r filename option token<<EOL
$1
EOL
echo "$filename$option$token" | grep -q '[^a-z0-9]' && exit 1
NOVOTES=/data/votes/novote.txt
TOKENS="/data/votes/tokens.txt" 
DATA="/data/votes/$filename"

# $DATA.options - possible options, 1 entry per line
# $DATA.vote2 # token date vote
# $DATA.sh # OUT_FILE OUT_URL

test -f "$DATA.sh" || exit 1
. "$DATA.sh"

### verify

grep -Fxq "$remote_ip" "$NOVOTES" && err "your IP blacklisted for voting"

test -z "$option" && local_perm_redir "$OUT_URL"
test -z "$token" && local_perm_redir "$OUT_URL"
grep -Fxq "$option" "$DATA.options" || local_perm_redir "$OUT_URL"
grep -q " $token$" "$TOKENS" || local_perm_redir "$OUT_URL"

### save

sed -i "/$token /d" "$DATA.vote2"
echo "$token $(date +'%F_%T') $option" >>"$DATA.vote2"

### patch/render

while read -r option; do
	votes="$(grep -c " $option$" "$DATA.vote2")"
	test "$votes" = 1 && pl='' || pl='s'
	echo "/^=> .vote.$filename.$option\\s/{s/([0-9]* votes\?)/($votes vote$pl)/;t;s/$/ ($votes vote$pl)/;}"
done <"$DATA.options" >/tmp/sed

sed -i -f /tmp/sed "$OUT_FILE"

### results

printf "20 text/gemini\r\n"
echo "Thank you for voting."
echo "=> $OUT_URL Go back to article"
echo "Note that depending on browser, you might need to refresh the article in order to see your vote"

#
exit 0
