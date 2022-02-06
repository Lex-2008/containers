#!/bin/false # this file should be sourced, not run

# config
filename="${1%%\?*}"
echo "$filename" | grep -q '[^a-zA-Z0-9_-]' && exit 1
DATA="/data/votes/$filename"
option="${1#*\?}"

# $DATA.options - possible options, 1 entry per line
# $DATA.votes # ip date vote
# $DATA.sh # OUT_FILE OUT_URL

test -f "$DATA.sh" || exit 1
. "$DATA.sh"

### verify

if test -z "$option"; then
	options="$(sed 's/$/, /' "$DATA.options" | tr -d '\n' | sed 's/[ ,]*$//')"
	ask "Enter one of: $options"
elif ! grep -Fxq "$option" "$DATA.options"; then
	options="$(sed 's/$/, /' "$DATA.options" | tr -d '\n' | sed 's/[ ,]*$//')"
	ask "Enter one of: $options"
fi

### save

sed -i "/$remote_ip /d" "$DATA.votes"
echo "$remote_ip $(date +'%F_%T') $option" >>"$DATA.votes"

### patch/render

while read -r option; do
	votes="$(grep -c " $option$" "$DATA.votes")"
	test "$votes" = 1 && pl='' || pl='s'
	echo "/^=> .vote.$filename.$option\\s/{s/([0-9]* votes\?)/($votes vote$pl)/;t;s/$/ ($votes vote$pl)/;}"
done <"$DATA.options" >/tmp/sed

sed -i -f /tmp/sed "$OUT_FILE"

### results

printf "20 text/gemini\r\n"
echo "Thank you for voting."
echo "=> $OUT_URL Go back to article"
echo "Note that depending on browser, you might need to refresh the article in order to see votes"

#
exit 0
