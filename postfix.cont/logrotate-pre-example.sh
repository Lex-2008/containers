#!/bin/bash
# prepend output of logshow script to a static file

cd /containers/nginx.cont/data/public/alexey.shpakovsky.ru/en/

savelog() {
	from="$1"
	to="${2-$from}"
	wget -q http://alexey.shpakovsky.ru/logshow/$from.sh -O $to.htm.new
	cat $to.htm >>$to.htm.new
	chown --reference=$to.htm $to.htm.new
	mv $to.htm.new $to.htm
}

savelog spam-emails spam-emails-3
savelog relay-attempts
savelog wrong-users
