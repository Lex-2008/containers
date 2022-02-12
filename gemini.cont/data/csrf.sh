#!/bin/false # this file should be sourced, not run

# uses:
# $filepath, $urlpath - to fill OUT_FILE and OUT_URL in $filename.sh
# $remote_ip

TOKENS="/data/votes/tokens.txt" # ip token
NOVOTES=/data/votes/novote.txt

# if you can't vote then I don't need to process links
grep -Fxq "$remote_ip" "$NOVOTES" && cat

# CSRF-protect vote links
while read -r line; do
	if ! echo "$line" | grep -q '^=> /vote/'; then
		echo "$line";
		continue;
	fi
	#                => /vote/filename[?/]option[ \t]title
	IFS=$' /?\t' read arrow vote filename option title<<-EOL
	$line
	EOL
	test -s "/data/votes/$filename.options" || collect_options=1
	test -z "$collect_options" || echo "$option" >>"/data/votes/$filename.options"
	if ! test -s "/data/votes/$filename.sh"; then
		echo "OUT_FILE=$filepath" >"/data/votes/$filename.sh"
		echo "OUT_URL=$urlpath" >>"/data/votes/$filename.sh"
	fi
	test -z "$token" && token="$(awk "/^$remote_ip /{ print \$2 }" "$TOKENS")"
	if test -z "$token"; then
		token="$(hexdump -e '"%02x"' -n 8 /dev/urandom)"
		echo "$remote_ip $token" >>"$TOKENS"
	fi
	echo "=> /vote/$filename/$option/$token $title"
done
