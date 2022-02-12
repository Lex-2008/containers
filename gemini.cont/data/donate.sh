#!/bin/false # this file should be sourced, not run

# config
DATA=/data/donations/$host.txt # ip gems * date gemline ["from" country]
			# 127.0.0.1 2 * 2022-02-05 GemGem from RU
OUT=/data/hosts/$host/donations.gmi
OUT_URL="/donations.gmi"
DONATE_URL="/donate"
gem='💎'
test -f "$OUT" || exit 1


they_give="$1"

### verify

if test -z "$they_give"; then
	ask "How many Gems would you like to donate?"
elif [[ "$they_give" =~ '^[1-9a-fA-F]$' ]] ; then
	they_give="$((16#$they_give))"
else
	ask "Please enter a positive one-digit number of how many gems you would like to donate:"
fi

### save

last_time="$(awk "/^$remote_ip /{ print \$2 }" "$DATA")"
test "$last_time" -gt "$they_give" && they_give="$last_time"

gemline="$(yes "$gem" | head -n "$they_give" | tr -d '\n')"

if ! test -z "$remote_ip"; then
	co="$(whois "$remote_ip" | awk '/[Cc]ountry/{print $2; exit}')"
	if test "co" != 'XX'; then
		if test "${#co}" = 2; then
			from="from $(echo "$from" | tr 'a-z' 'A-Z' | ./co2flag.sh)"
		else
			from="from $co"
		fi
	fi
fi

sed -i "/$remote_ip /d" "$DATA"
echo "$remote_ip $they_give * $(date +'%F') $gemline $from" >>"$DATA"



### render

ips="$(cat "$DATA" | wc -l)"
gems="$(awk '{ sum += $2 } END { print sum }' "$DATA")"
# https://stackoverflow.com/questions/2702564/how-can-i-quickly-sum-all-numbers-in-a-file

# sed: wait for 1st empty line; skip over non-empty lines; print rest
sed -n '/^$/{:a;n;/^$/!ba;:b;n;p;bb;}' "$OUT" >/tmp/outtail

{
	echo "# $gem DONATIONS $gem"
	echo "Total received: $gem$gems from $ips donors:"
	echo ''
	cut -d' ' -f '3-' "$DATA"
	echo ''
	cat /tmp/outtail
} >"$OUT"
rm /tmp/outtail

### results

printf "20 text/gemini\r\n"
echo "You've donated $gem$they_give."
echo "=> $OUT_URL See past donations"
exit 0
