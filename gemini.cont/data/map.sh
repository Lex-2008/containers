#!/bin/sh

# config
LOG=/data/logs/gemini.log # date time ip request
DATA=/data/logs/map.txt # date time ip request
OUT=/data/hosts/alexey.shpakovsky.ru/map.gmi
test -f "$LOG" || exit 1

ff="🎌"

cut -d' ' -f3 "$LOG" | sort -u | while read -r ip; do
	grep -q "^$ip " "$DATA" && continue
	echo -n "$ip "
	user_co="$(timeout 5 whois "$ip" | awk '/[Cc]ountry/{print $2; exit}' | tr 'a-z' 'A-Z' | tr -cd 'A-Z' )"
	echo "[$user_co]"
	if test -z "$user_co"; then
		user_co='??'
		user_flag="$ff"
	else
		user_flag="$(echo "$user_co" | ./co2flag.sh)"
	fi
	echo "$ip $user_co $user_flag" >>"$DATA"
done

### render

visits="$(cat "$DATA" | wc -l)"
uniqs="$(cut -d' ' -f3- "$DATA" | sort -u | wc -l)"

{
	echo "total $visits IPs from $uniqs countries"
	cut -d' ' -f2- "$DATA" | sort | uniq -c | sort -rn | while read -r num co flag; do
		echo -n "$co $num: "
		printf "$flag%.0s " `seq $num`
		echo ''
	done
} >"$OUT"

