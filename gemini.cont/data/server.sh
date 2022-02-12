#!/bin/sh
read -r request

# check if first line is from PROXY protocol
if test "${request::6}" = "PROXY "; then
	remote_ip="$(echo "$request" | cut -d' ' -f3)"
	read -r request
fi

# strip LF at the end
r="$(echo -e "\r")"
request="${request%$r}"

# $request looks like this
# gemini://localhost[:port][/path/to]

grep -Fxq "$remote_ip" /data/logs/nolog.txt || echo "$(date +"%F %T") $remote_ip $request" >>/data/logs/gemini.log

# test and strip protocol
if test "${request::9}" = "gemini://"; then
	protocol='gemini'
	noproto="${request:9}"
elif test "${request::8}" = "titan://"; then
	protocol='titan'
	noproto="${request:8}"
else
	exit 1
fi
# $noproto looks like this:
# localhost[:port][/path/to]

host="${noproto%%/*}"
urlpath="${noproto:${#host}}"
host="${host%:*}"
# at this point, $urlpath is either empty or starts with /

test -z "$host" && host="empty"
# TODO: what if $host is percent-encoded?
# TODO: what if $host or $urlpath has spaces or newlines?

### some helper functions
function local_perm_redir() {
# TODO: do we need to percent-encode URLs before redirecting?
# if no: how gemini clients will react if server redirects them to non-percent-encoded utf8 URL?
# if yes: how gemini clients will react if server redirects them to URL longer than max-len?
# (I'm considering encoding all letters, including English ones)
# Theoretical question: And what if redirect is to a different server?
	echo -e "31 gemini://$host$1\r\n"
	exit 0
}

function ask() {
	echo -e "10 $1\r\n"
	exit 0
}

function mime() {
	# given a filename, print its mime type.
	# for some inspiration, see
	# https://github.com/nginx/nginx/blob/master/conf/mime.types
	# https://github.com/lighttpd/lighttpd1.4/blob/master/doc/config/conf.d/mime.conf
	case $1 in
		( *.gmi | *.gemini ) echo "text/gemini" ;;
		( *.atom ) echo "application/atom+xml" ;;
		( *.rss ) echo "application/rss+xml" ;;
		( *.jpg | *.jpeg ) echo "image/jpeg" ;;
		( *.png ) echo "image/png" ;;
		( *.gif ) echo "image/gif" ;;
		( *.txt | *.sh ) echo "text/plain" ;;
		( * ) file -bi "$1" || echo "application/octet-stream" ;;
	esac
}

# redirect empty path to /
test -z "$urlpath" && local_perm_redir "/"

# decode percent-encoding
# from https://stackoverflow.com/questions/6250698/how-to-decode-url-encoded-string-in-shell
urlpath="$(echo -e "${urlpath//%/\\x}")"

# Note that urlpath might have ?query for input lines,
# or ;param;params for titan uploads

hostroot="/data/hosts/$host/"
# assume no dir/file-names have ; in them - titan requirement
filepath="$(realpath "$hostroot${urlpath%%;*}")"



# TODO: you can add dynamics here
# you can either return whatever you want,
# or adjust $filepath and $mime/$lang to your liking
# Remember to disable path traversal, if it's applicable to you

# we compare with "request", since it has protocol,
# but pass urlpath since it's shorter and %-decoded
test "${request::35}" = "gemini://alexey.shpakovsky.ru/vote/" && . /data/vote.sh "${urlpath:6}"

# we compare with "request", since it has protocol, but pass urlpath since it's shorter
test "${request::36}" = "gemini://alexey.shpakovsky.ru/donate" && . /data/donate.sh "${urlpath:8}"

test "${request::32}" = "gemini://alexey.shpakovsky.ru/ru" && lang="; lang=ru"
test "$host" = "stalker.shpakovsky.ru" && lang="; lang=ru"



# serve static files from $filepath

# Check for empty filepath - it happens when filepath goes into a non-existing dir
if test -z "$filepath"; then
	echo -en "20 text/plain\r\n"
	echo "51 NOT FOUND"
	echo "path: [$urlpath]"
	echo "root: [$hostroot]"
	exit 1
fi

# Disable path traversal. Note that dynamics above must do it themselves:
# a) they might want it (comments in guestbook?)
# b) realpath doesn't work for non-existing dirs
# Also note that for dirs, realpath returns them without trailing /,
# so root path must be checked separately
if test "$filepath/" != "$hostroot" -a "${filepath::${#hostroot}}" != "$hostroot"; then
	echo -en "20 text/gemini\r\n"
	echo "# Sorry!"
	echo "Path traversal is disabled on this server. Have a look at source code for this server, instead:"
	echo '```'
	cat "$0"
	echo '```'
	exit 1
fi

index_file="index.gmi"

# # Strip $index_file from $urlpath via redirect.
# # Note that at this point, the file is guaranteed to exist
# # (otherwise, execution would stop earlier)
# test "${urlpath: -10}" = "/$index_file" && local_perm_redir "${urlpath::-9}"

# serve directory
if test -d "$filepath"; then
	# Servers MUST add missing / at the end of directory names
	# and redirect clients from /dir to /dir/.
	# Otherwise, link to "somewhere" on page /path/to/something
	# will lead browsers to "/path/to/somewhere"
	# instead of "/path/to/something/somewhere"
	# this concerns only gemini, since titan has ;params at the end of urlpath
	test "$protocol" = 'gemini' -a "${urlpath: -1}" != '/' && local_perm_redir "$urlpath/"
	# When requesting a directory, show index.gmi file instead.
	# For titan we do it always, for gemini - only if file exists
	if test "$protocol" = 'titan' -o -f "$filepath/$index_file"; then
		filepath="$filepath/$index_file"
	else
		# TODO: generate directory listing
		false
	fi
fi

if test "$protocol" = 'gemini'; then
	if test -f "$filepath"; then
		# serve static file
		test -z "$mime" && mime="$(mime "$filepath")"
		echo -en "20 $mime$lang\r\n"
		cat "$filepath"
		exit 0
	else
		echo -en "20 text/plain\r\n"
		echo "51 NOT FOUND"
		echo "host: [$host]"
		echo "path: [$urlpath]"
		echo "file: [$filepath]"
		exit 1
	fi
elif test "$protocol" = 'titan'; then
	# upload via titan
	perms_file="/data/titan/$host.txt"
	test -f "$perms_file" || exit 1
	# sed hint: if s/// failed, returned value is empty (`d`)
	size="$(echo "$urlpath" | sed -r 's/.*;size=([^;]*)(;.*|$)/\1/;t;d')"
	test -z "$size" && exit 1
	token="$(echo "$urlpath" | sed -r 's/.*;token=([^;]*)(;.*|$)/\1/;t;d' | md5sum | sed 's/\s.*//')"
	token_ok=''
	while read -r perm_line; do
		# echo expr "$token ${filepath:${#hostroot}}" : "$perm_line"
		if expr "$token ${filepath:${#hostroot}}" : "$perm_line" >/dev/null; then
			token_ok=1
			break
		fi
	done <"$perms_file"
	if test -z "$token_ok"; then
		echo -en "50 Bad token: [$token]\r\n"
		exit 1
	fi
	# Note: we can't use cat here, it hangs
	head -c "$size" >"$filepath"
	echo -e "30 gemini://$host${urlpath%%;*}\r\n"
	exit 0
fi

# should not reach
echo -en "50 End of script reached\r\n"
