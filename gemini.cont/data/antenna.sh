old=/data/data/antenna.txt
new=/data/data/antenna.txt.new
HOT='🆕 '
out="/data/data/antenna.gmi"

printf "20 text/gemini\r\n"
echo '# Antenna proxy'
echo '=> gemini://warmedal.se/~antenna/ Original Antenna by ew0k'
echo 'This one just fetches links from there, adding datetime when they were discovered.'

age=$((`date +%s` - `date -r "$out" +%s`))
if test $age -lt 600; then
	echo "You're looking at a cached version from $(date -r "$out" +'%H:%M'). It was updated $age seconds ago. Next update in $((600 - age)) seconds."
	cat "$out"
	exit 0
fi

echo "This page was updated right now, at $(date +'%H:%M')"

now="$((`date +%s`/300*300))"
now_dt="$(date -d@"$now" +'%F %H:%M')"

wget -qO- 'http://portal.mozz.us/gemini/warmedal.se/~antenna/?raw=1' | \
while read -r arrow url date title; do
	test "$arrow" = '=>' || continue
	[[ "$date" =~ [0-9]{4}-[0-9]{2}-[0-9]{2} ]] || continue
	hash="$(echo "$url" | md5sum | head -c32)"
	datetime="$(awk "/^$hash /{print \$2, \$3}" "$old")"
	# test -z "$datetime" && datetime="$date 00:00"
	test -z "$datetime" && datetime="$now_dt"
	echo "$hash $datetime" >>"$new"
	echo "$datetime $date $url $title"
done | sort -r | tee /tmp/sorted | while read -r date time xdate url title; do
	test "$date $time" = "$now_dt" && hot="$HOT" || hot=''
	test "$oldate" = "$date" || echo ''
	test "$oldate" != "$date" -a "$date" = "2022-02-13" && echo 'Entries before and including this date were filled in retrospectively.'
	echo "=> $url $hot$date $time $title"
	oldate="$date"
done | tee "$out"

# touch -d@"$now" "$out"
mv "$new" "$old"
exit 0
