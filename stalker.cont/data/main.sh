#!/bin/sh

robotstxt() {
	# given a hostname,
	# fetches new robots.txt for `host`
	# and returns 1 if it differs from prev one
	host="$1"
	new="robotstxt/$host.new"
	old="robotstxt/$host.old"
	url="gemini://$host/robots.txt"
	url1="$url?robot=true&uri=gemini://stalker.shpakovsky.ru/about.gmi"
	# TODO: skip if $new is rather new
	echo "$url1" | timeout 10 openssl s_client -crlf -connect $host:1965 -quiet 2>/dev/null >&2 &
	echo "$url" | timeout 10 openssl s_client -crlf -connect $host:1965 -quiet 2>/dev/null >"$new"
	if ! test -s "$new"; then
		sleep 10
		echo "$url" | timeout 10 openssl s_client -crlf -connect $host:1965 -quiet 2>/dev/null >"$new"
	fi
	diff -q "$old" "$new" >/dev/null
}

dosite_main() {
	base="$1"
	index="$2"
	deindex="$3"
	delline="$4"
	maxurlcount="$5"
	host="${base:9}"
	host="${host%%/*}"
	title="${base:9:-1}"
	robotstxt "$host"; # fetch new robots.txt
	bad_robotstxt="$?" # 0 if good
	if ! test -s "robotstxt/$host.new"; then
		echo "$host" >>"$tmp-skipped.txt"
		return 1
	elif ! test "$bad_robotstxt" = 0; then
		echo '' >>"$OUTFILE"
		echo "### $title" >>"$OUTFILE"
		echo "> Сайт пропущен из-за изменений в файле robots.txt" >>"$OUTFILE"
		return 1
	fi
	dirname="$(echo "${base:9:-1}" | sed 's_/_-_g')"
	new="data/$dirname.new"
	old="data/$dirname"
	bak="bak/$dirname"
	mkdir -p "$new"
	./mirror.sh "$host" "$base" "$new" "$index" "$deindex" "$maxurlcount"
	if test "$delline"; then
		# delete all *.dat files containing delline
		grep -lFx "$delline" "$new"/*.dat | xargs rm
	fi
	./diffsite.sh "$old" "$new" "$OUTDIR" "$tmp-site"
	if test -s "$tmp-site"; then
		echo '' >>"$OUTFILE"
		echo "### $title" >>"$OUTFILE"
		cat "$tmp-site" >>"$OUTFILE"
		touch "last-update/$dirname"
	fi
	rm -rf "$bak"
	mv "$old" "$bak"
	mv "$new" "$old"
}

dosite_robotstxt() {
	base="$1"
	host="${base:9}"
	host="${host%%/*}"
	robotstxt "$host" && return 0 # fetch new robots.txt and exit if it matches
	test -s "robotstxt/$host.new" || return 1 # exit if new robots.txt is empty (site offline)
	# otherwise, show diff
	new="robotstxt/$host.new"
	old="robotstxt/$host.old"
	echo "======================"
	echo "robots.txt differ for: $base"
	echo "=== old robots.txt ==="
	cat "$old"
	echo "=== new robots.txt ==="
	cat "$new"
	echo "===   difference   ==="
	diff "$old" "$new"
	echo "=== please investagate and fix:"
	echo "mv $new $old"
}

dosite_diff() {
	base="$1"
	title="${base:9:-1}"
	dirname="$(echo "${base:9:-1}" | sed 's_/_-_g')"
	new="data/$dirname"
	old="bak/$dirname"
	./diffsite.sh "$old" "$new" "$OUTDIR" "$tmp-site"
	if test -s "$tmp-site"; then
		echo '' >>"$OUTFILE"
		echo "### $title" >>"$OUTFILE"
		cat "$tmp-site" >>"$OUTFILE"
	fi
}

OUTDIR=/ext
OUTFILE="$OUTDIR/today.gmi"
OUTFILE_BAK="$OUTDIR/today.gmi.bak"
INDEXFILE_NEW="$OUTDIR/index.new" # tmp file to move/rename over real file
INDEXFILE_REAL="$OUTDIR/index.gmi"
INDEXFILE_REAL_BAK="$OUTDIR/index.gmi.bak"

tmp=/tmp/main

case "$1" in
	( robotstxt )
		mkdir -p robotstxt
		alias dosite=dosite_robotstxt
		;;
	( main )
		mkdir -p "$OUTDIR"
		mv "$OUTFILE" "$OUTFILE_BAK"
		rm -f "$tmp-skipped.txt"
		alias dosite=dosite_main
		;;
	( diff )
		mkdir -p "$OUTDIR"
		mv "$OUTFILE" "$OUTFILE_BAK"
		alias dosite=dosite_diff
		;;
	( * )
		echo "provide one of: robotstxt, main, diff"
		exit 1
esac

dosite gemini://alexey.shpakovsky.ru/rulog/
dosite gemini://armitage.flounder.online/ index.gmi
# dosite gemini://basnja.ru/ # too big
dosite gemini://byzoni.org/ index.gmi
dosite gemini://davincis23.cities.yesterweb.org/
dosite gemini://feerzlay.ru/
dosite gemini://flayer.vern.cc/ index.gmi
dosite gemini://geddit.phreedom.club/
dosite gemini://gemini.quietplace.xyz/
dosite gemini://gemlog.blue/users/3550/
dosite gemini://3550.cities.yesterweb.org/ index.gmi
dosite gemini://gemlog.blue/users/abrbus/
dosite gemini://gemlog.blue/users/musu_pilseta/
dosite gemini://gemlog.blue/users/ScottLoard/
dosite gemini://gemlog.blue/users/spelltoad/
# dosite gemini://gemlog.stargrave.org/ '?offset=0' # too big
dosite gemini://hsdchannel.cities.yesterweb.org/ index.gmi
dosite gemini://hugeping.ru/
dosite gemini://karabas.flounder.online/
dosite gemini://kirill.zholnay.name/
dosite gemini://lesarbr.es/
dosite gemini://levochki.sysrq.in/
dosite gemini://mo.rijndael.cc/
dosite gemini://offpunk.com/
dosite gemini://omega9.flounder.online/
dosite gemini://ostov.ml/
dosite gemini://parthen.smol.pub/
dosite gemini://phreedom.club/ '' index.gmi
dosite gemini://pub.phreedom.club/ '' '' '' 500
dosite gemini://sdf.org/xyz/
dosite gemini://simonvolpert.com/
dosite gemini://spiri-leo.cities.yesterweb.org/
dosite gemini://spline-online.tk/
dosite gemini://stalker.shpakovsky.ru/ about.gmi
dosite gemini://subpoena.gleeze.com/
dosite gemini://sysrq.in/ru/
dosite gemini://textgamesinfo.ru/
dosite gemini://things.leemoon.network/
dosite gemini://tilde.team/~avarnex/ index.gmi
dosite gemini://tilde.team/~kull/
dosite gemini://tilde.team/~rami/ index.gmi '' '' 500
dosite gemini://tilde.team/~runation/ index.gmi
dosite gemini://topotun.dynu.com/ index.gmi
dosite gemini://ychbn.flounder.online/ index.gmi

# c https://stackoverflow.com/a/15515152
# mind corner cases - not applicable for us
exists() {
    [ -e "$1" ]
}

case "$1" in
	( main | diff )
		visited="$(cat data/*/visited_urls.txt | wc -l)"
		saved="$(ls data/*/*.dat | wc -l)"
		gemtext="$(head -qn1 data/*/*.dat | grep '20 text/gemini' | wc -l)"
		size="$(du -hs data | sed 's/\s.*//')"

		# rebuild indexfile
		{
			sed '/^##/,$d' "$INDEXFILE_REAL" 
			echo "## $(date -d yesterday +%F)"
			echo "Адресов посещено: $visited, страниц сохранено: $saved, из них gemtext: $gemtext. Общий объем: $size."

			if exists data/*/warning.txt; then
				cat data/*/warning.txt
			fi

			if test -s "$OUTFILE"; then
				cat "$OUTFILE"
			else
				echo ''
				echo "Изменений не обнаружено."
			fi

			if test -s "$tmp-skipped.txt"; then
				cat "$tmp-skipped.txt" | sort -u >"$tmp-skipped.sorted"
				echo ''
				if test "$(cat "$tmp-skipped.sorted" | wc -l)" = 1; then
					echo "Нет связи с капуслой: $(cat "$tmp-skipped.sorted")"
				else
					skipped="$(cat "$tmp-skipped.sorted" | tr '\n' ' ')"
					echo "Нет связи с капуслами: $skipped"
				fi
			fi
			echo ''
			w="## $(date -d '8 days ago' +%F)"
			sed -n "/^##/,\${1,/^$w/{/$w/!p}}" "$INDEXFILE_REAL" 
		} >"$INDEXFILE_NEW"
		
		# move/rename it on top of the real thing
		cp "$INDEXFILE_REAL" "$INDEXFILE_REAL_BAK"
		mv "$INDEXFILE_NEW" "$INDEXFILE_REAL"

		# delete old diffs
		# +6 should be enough
		find "$OUTDIR" -name 'diff-*' -mtime +7 -delete

		cp ./nogo.txt "$OUTDIR/nogo.txt"
		;;
esac

