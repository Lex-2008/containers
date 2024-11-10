#!/bin/sh

OUT=/out
TIMES="$OUT/times.html"

# delete duplicate description files
ls *.description | cut -c10-20 | uniq -c | awk '$1=='2' {print $2}' | xargs -I % sh -c 'rm *%*'

ls *.description | python3 recent.py 7 youtube >da.txt

set -x

if test -f yt-dlp; then
	./yt-dlp -U
else
	python3 -c 'import urllib.request; urllib.request.urlretrieve("https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp", "asd")'
	chmod a+x ./yt-dlp
fi

./yt-dlp --ignore-errors --write-auto-sub --sub-lang ru --sub-format srv1 --skip-download --write-description -o '%(upload_date)s-%(id)s-%(title)s.%(ext)s' --download-archive da.txt 'https://www.youtube.com/channel/UCXJYy66gIOEsT04ndBUBFPw'

# rm channel description
rm NA-UCXJYy66gIOEsT04ndBUBFPw*

cp template.txt subs.txt

sed '/HERE/,$d' template.html >"$TIMES"

set +x

export IFS='
'

for f in `ls -1 *.description`; do
	fn="`echo "$f" | sed -r 's/.description$//'`"
	id="`echo "$fn" | cut -c 10-20`"
	url="https://www.youtube.com/watch?v=$id"
	date="`echo "$fn" | sed -r 's/^(....)(..)(..).*/\1-\2-\3/'`"
	title="`echo "$fn" | cut -c 22-`"

	echo "$id / $date / $title" >&2

	exec >>"$TIMES"

	echo "<details id="s$id"><summary><h2><a href='$url'>$date</a> - $title</h2></summary>"
	cat $fn.description | python3 linkify.py "$url&t=" | sed 's/$/<br>/'
	echo '</details>'

	test -f $fn.ru.srv1 || continue

	exec >>subs.txt

	echo "$date - $title"
	echo "$url"
	echo "$url" | sed 's/./=/g'
	cat $fn.description
	echo
	echo "$url" | sed 's/./-/g'
	# TI:ME only
	# cat $fn.ru.ttml | sed -r '/^<p/!d;s!<p begin="([0-9:]*)[^>]*>(.*)</p>$!\1 \2!'
	# youtube://URL
	cat $fn.ru.srv1 | sed 's/<text start="/\n/g' | sed -r "1d;s!^([0-9]*)[^>]*>(.*)</text>.*!$url\&t=\1s \2!"
	echo
	echo
	
done

exec >/dev/null

set -x

sed '1,/HERE/d' template.html >>"$TIMES"
gzip -kf "$TIMES"

zip -1l subs.zip subs.txt
gzip -1f subs.txt

# this file must contain usernames and passwords for services used further,
# in format like this:
# SERVICE_USERPASS=username:password
. ./secrets.txt

#curl --silent --user "$CHATRU_USERPASS" --upload-file index.koi8r.html ftp://ancha-times.chat.ru/index.html
curl --silent --user "$MAILRU_USERPASS" --upload-file subs.zip "https://webdav.cloud.mail.ru/subs.zip"
curl --silent --user "$MAILRU_USERPASS" --upload-file subs.txt.gz "https://webdav.cloud.mail.ru/subs.txt.gz"

rm subs.*
