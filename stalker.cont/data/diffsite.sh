#!/bin/sh
#
# a simple script to diff a gemini capsule
#
# args:
#  dir with old files
#  dir with new files
#  dir to save diff files
#  filename to save final output

OLD="$1"
NEW="$2"
OUT="$3"
OUTFILE="$4"

tmp=/tmp/diff

mkdir -p "$NEW"


cat "$NEW"/*.url | sort >"$tmp-new.txt"
cat "$OLD"/*.url | sort >"$tmp-old.txt"

comm -2 -3 "$tmp-new.txt" "$tmp-old.txt" | sed 's/.*/=> & & [НОВ]/' >"$OUTFILE"

comm -2 -3 "$tmp-old.txt" "$tmp-new.txt" | sed 's/.*/* & [УДЛ]/' >"$tmp-del.txt"

( cd "$NEW"; ls *.dat) | sort >"$tmp-new.txt"
( cd "$OLD"; ls *.dat) | sort >"$tmp-old.txt"

comm -1 -2 "$tmp-new.txt" "$tmp-old.txt" >"$tmp-both.txt"

rm -f "$tmp-out.txt"

while read -r line; do
	difffn="diff-$RANDOM-$RANDOM.txt"
	diff="$OUT/$difffn"
	diff "$OLD/$line" "$NEW/$line" >"$diff"
	if ! test -s "$diff"; then
		rm "$diff"
		continue
	fi
	remlines="$(grep -c '^<' "$diff")"
	addlines="$(grep -c '^>' "$diff")"
	if test "$remlines" = 0; then
		mod="ДОБ +$addlines"
	elif test "$addlines" = 0; then
		mod="УБР -$remlines"
	else
		mod="+$addlines/-$remlines"
	fi
	url="$(cat "$OLD/${line%.dat}.url")"
	#relurl="${url: -${#BASE}}" # we don't have BASE here anymore
	echo "=> $url $url [ИЗМ]">>"$tmp-out.txt"
	echo "=> $difffn $url [$mod]">>"$tmp-out.txt"
done <"$tmp-both.txt"

sort "$tmp-out.txt" >>"$OUTFILE"

cat "$tmp-del.txt" >>"$OUTFILE"
