#!/bin/false # this file should be sourced, not run

# config
DATA=/data/flags/$host.txt # ip datetime countryname countryflag
OUT1=/data/hosts/$host/flags.gmi
OUT2=/data/hosts/$host/rulog/flags.gmi
test -f "$DATA" || exit 1

lang="$1"

INTRO1='# $ff FLAGS $ff
Total $visits flags from $uniqs countries:'
INTRO2='# $ff ФЛАГИ $ff
Всего флагов: $visits, уникальных стран: $uniqs:'

ff="🎌"

### verify

test -z "$remote_ip" && exit 1


### save

user_co="$(timeout 5 whois "$remote_ip" | awk '/[Cc]ountry/{print $2; exit}' | tr 'a-z' 'A-Z' | tr -cd 'A-Z' )"

if test -z "$user_co"; then
	user_co='??'
	user_flag="$ff"
else
	user_flag="$(echo "$user_co" | ./co2flag.sh)"
fi

sed -i "/$remote_ip /d" "$DATA"
echo "$remote_ip $(date +'%F_%T') $user_co $user_flag" >>"$DATA"



### render

visits="$(cat "$DATA" | wc -l)"
uniqs="$(cut -d' ' -f4- "$DATA" | sort -u | wc -l)"

# common part for ru and en
{
	echo ''
	cut -d' ' -f3- "$DATA" | sort | uniq -c | sort -rn | while read -r num co flag; do
		echo -n "$co $num: "
		# 'yes' seems to run away, hang and never end
		# yes "$flag" | head -n "$num" | tr '\n' ' '
		printf "$flag%.0s " `seq $num`
		echo ''
	done
	echo ''
} >/tmp/flagblock

export ff visits uniqs

# sed: wait for 1st empty line; skip over non-empty lines; print rest
sed -n '/^$/{:a;n;/^$/!ba;:b;n;p;bb;}' "$OUT1" >/tmp/out1
{
	echo "$INTRO1" | envsubst '$ff $visits $uniqs'
	cat /tmp/flagblock
	cat /tmp/out1
} >"$OUT1"

sed -n '/^$/{:a;n;/^$/!ba;:b;n;p;bb;}' "$OUT2" >/tmp/out2
{
	echo "$INTRO2" | envsubst '$ff $visits $uniqs'
	cat /tmp/flagblock
	cat /tmp/out2
} >"$OUT2"


rm /tmp/out1 /tmp/out2 /tmp/flagblock

### results

printf "20 text/gemini\r\n"
case "$lang" in
	( en )
echo "Thank you for adding you flag: $user_co $user_flag
=> /flags.gmi See updated list of flags
Note that depending on browser, you might need to refresh the page in order to see updates"
	;;
	( ru )
echo "Спасибо, что добавили свой флаг: $user_co $user_flag
=> /flags.gmi Посмотреть обновленный список флагов
Обратите внимание, что в зависимости от браузера, Вам может понадобиться перезагрузать страницу чтобы увидеть изменения"
	;;
esac

# echo "Thank you for adding you flag: $user_co $user_flag"
# echo "=> $OUT_URL See updated list of flags"
# echo "Note that depending on browser, you might need to refresh the page in order to see updates"
exit 0
