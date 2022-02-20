#!/bin/false # this file should be sourced, not run

req="$1"

case "$req" in
	( '/whois' )

		filename="/tmp/whois-$(echo "$remote_ip" | md5sum | head -c32)"
		test -f "$filename" || timeout 5 whois "$remote_ip" >"$filename"
		user_co="$(cat "$filename" | awk '/[Cc]ountry/{print $2; exit}' | tr 'a-z' 'A-Z' | tr -cd 'A-Z' )"
		if test "${#user_co}" = 2; then
			user_flag=" $(echo "$user_co" | ./co2flag.sh)"
		fi

		printf "20 text/gemini\r\n"
		echo '# WHOIS'
		echo ''
		echo "Whois data for your IP: $remote_ip:$user_flag"
		echo ''
		echo '```'
		cat "$filename"
		echo '```'

		;;
	( * )

		printf "20 text/gemini\r\n"
		echo "# Your IP

		Your IP is: $remote_ip

		=> /whois	WHOIS information about your IP

		=> gemini://ip4.shpakovsky.ru/ IPv4-only test
		=> gemini://ip6.shpakovsky.ru/ IPv6-only test
		" | sed 's/^\t*//'

		;;
esac
exit 0
