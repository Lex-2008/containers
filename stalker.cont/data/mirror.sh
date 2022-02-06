#!/bin/sh
#
# a simple script to mirror a gemini capsule
#
# args:
#  host to connect to
#  base URL to look under
#  dir to save output
#  start page to start mirroring from
#  filename to strip from URLs ('index.gmi' to index directories only once)

HOST="$1"
BASE="$2"
DATA="$3"
index="$4"
deindex="$5"

tmp=/tmp/mirror
tab="$(echo -e '\t')"

get() {
	# pass URL and file where to save to
	echo "$1" | timeout 7 openssl s_client -crlf -connect $HOST:1965 -quiet 2>/dev/null | sed '1{/20 text/!q}' >"$2"
}

extract_urls() {
	# pass gemfile, its URL, and a file where to put URLs
	sed -r '/^=>/!d;s/^=>\s*(\S*).*/\1/' "$1" | ./rel2abs.py "$2" >>"$3"
}

extract_redir() {
	# pass gemfile, its URL, and a file where to put URLs
	sed -rn '/^3. /!q;s/3. (\S*)/\1/;p;q' "$1" | ./rel2abs.py "$2" >"$3"
}

new_local_urls() {
	# pass file with URLs, file with existing URLs, and where to put result
	# Note: sed expression in the middle replaces all // with / except 1st one.
	# I'm not 100% sure that's always desired (what if you have base64 URL?)
	# but sometimes needed
	cat "$1" | ./filter.py "$BASE" | sed 's_///*_/_g;s_/_//_' | sort -u >"$tmp-comm"
	# if 'deindex' was requested, strip it from the end of directory, f.ex.
	# dir/index.gmi => dir/
	# useful when a site is known to have links both to dir/ and dir/index.gmi
	if test "$deindex"; then
		sed "s_/$deindex\$_/_" "$tmp-comm" >"$tmp-comm1"
		sort -u "$tmp-comm1" >"$tmp-comm"
	fi
	comm -2 -3 "$tmp-comm" "$2" >"$3"
}

echo "$BASE$index" >"$tmp-thisurls.txt"
mkdir -p "$DATA"
rm -f "$tmp-hasurls.txt"

while test -s "$tmp-thisurls.txt"; do
	# echo "starting new round with following URLs:"
	# cat "$tmp-thisurls.txt"
	# echo "--------------------------------------"
	rm -f "$tmp-newurls.txt"
	while read -r url; do
		n="$DATA/$(echo "$url" | md5sum | sed 's/ .*//')"
		echo "$url" >>"$tmp-hasurls.txt"
		get "$url" "$n.dat"
		echo "$url$tab=> $(head -n1 "$n.dat")"
		sleep 3
		if head -n1 "$n.dat" | grep -q '^3. '; then
			extract_redir "$n.dat" "$url" "$n.urls"
			cat "$n.urls" >>"$tmp-newurls.txt"
			rm "$n.dat" "$n.urls"
			continue
		elif ! head -n1 "$n.dat" | grep -q '^20 text/'; then
			rm "$n.dat"
			continue
		fi
		echo "$url" >"$n.url"
		extract_urls "$n.dat" "$url" "$n.urls"
		cat "$n.urls" >>"$tmp-newurls.txt"
		# if test -s "$n.urls"; then
		# 	echo "  extracted URLs:"
		# 	sed 's/.*/    &/' "$n.urls"
		# else
		# 	echo "  no URLs extracted"
		# fi
		# echo "  -----------------"
	done <"$tmp-thisurls.txt"
	sort "$tmp-hasurls.txt" >"$tmp-hasurls.sorted"
	test -s "$tmp-thisurls.txt" || break
	new_local_urls "$tmp-newurls.txt" "$tmp-hasurls.sorted" "$tmp-thisurls.txt"
	urlcount="$(cat "$tmp-hasurls.sorted" "$tmp-thisurls.txt" | wc -l)"
	if test "$urlcount" -ge 200; then
		echo '' | tee -a "$DATA/warning.txt"
		echo "Запредельное значение счетчика ссылок: $urlcount, новые (пропущенные) адреса:" | tee -a "$DATA/warning.txt"
		cat "$tmp-thisurls.txt" | tee -a "$DATA/warning.txt"
		test -z "$SKIP_URL_LIMIT" && break
		echo -n "Hit Enter to continue"
		read
	fi
	# echo "======================================"
done
mv "$tmp-hasurls.sorted" "$DATA/visited_urls.txt"
