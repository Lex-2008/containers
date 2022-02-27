#!/bin/false # this file should be sourced, not run

# config
# $2 is filename/option/token
#    or filename?option
IFS='/?' read -r filename option token<<EOL
$2
EOL
echo "$filename$option$token" | grep -q '[^a-z0-9]' && exit 1
lang="$1"
NOVOTES=/data/votes/novote.txt
TOKENS="/data/votes/tokens.txt" 
YESTERTOKENS="/data/votes/yestertokens.txt"
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

vote_ip="$(awk "/ $token$/{ print \$1 }" "$TOKENS" "$YESTERTOKENS")"

if test -z "$vote_ip"; then
	printf "20 text/gemini\r\n"
	case "$lang" in
		( en )
			echo 'Your voting link have expired. Please:'
			echo "=> $OUT_URL 1. Go back to article"
			echo '2. Refresh / reload it'
			echo '3. And vote again'
			echo 'If error persists, send me an email.'
			;;
		( ru )
			echo 'Ваша ссылка для голосования устарела. Пожалуйста:'
			echo "=> $OUT_URL 1. Перейдите к записи"
			echo '2. Обновите её'
			echo '3. Проголосуйте ещё раз'
			echo 'Если ошибка повторится - напишиште мне на почту.'
			;;
	esac
	exit 0
fi

### save

sed -i "/$vote_ip /d" "$DATA.votes"
echo "$vote_ip $(date +'%F_%T') $option" >>"$DATA.votes"

### patch/render

case "$lang" in
	( en )
		while read -r option; do
			votes="$(grep -c " $option$" "$DATA.votes")"
			test "$votes" = 1 && pl='' || pl='s'
			echo "/^=> .vote.$filename.$option\\s/{s/([0-9]* votes\?)/($votes vote$pl)/;t;s/$/ ($votes vote$pl)/;}"
		done <"$DATA.options" >/tmp/sed
		;;
	( ru )
		while read -r option; do
			votes="$(grep -c " $option$" "$DATA.votes")"
			# based on https://habr.com/ru/post/105428/#comment_3317882
			pl='ов'
			[[ "$votes" =~ [234]$ ]] && pl='а'
			[[ "$votes" =~ 1$ ]] && pl=''
			[[ "$votes" =~ 1[0-9]$ ]] && pl='ов'
			echo "/^=> .voteru.$filename.$option\\s/{s/([0-9]* голос.*)/($votes голос$pl)/;t;s/$/ ($votes голос$pl)/;}"
		done <"$DATA.options" >/tmp/sed
		;;
esac

sed -i -f /tmp/sed "$OUT_FILE"

### results

printf "20 text/gemini\r\n"
case "$lang" in
	( en )
		echo "Thank you for voting."
		echo "=> $OUT_URL Go back to article"
		echo "Note that depending on browser, you might need to refresh the article in order to see your vote"
		;;
	( ru )
		echo "Спасибо за Ваш голос."
		echo "=> $OUT_URL Вернуться"
		echo "В зависимости от браузера, Вам может понадобиться перезагрузить страницу, чтобы увидеть результат"
		;;
esac

#
exit 0
