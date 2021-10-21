user="${1:?first arg must be username}"
pass="$2"
if [ -z "$pass" ]; then
	echo "generating password..."
	pass="$(docker run --rm alpine sh -c 'apk add --quiet --no-cache pwgen && pwgen 8 1')"
	echo "New password: $pass"
fi

domain=shpakovsky.ru
email="$user@$domain"

echo "encrypting password..."
pwline="$(docker run --rm alpine sh -c "apk add --quiet --no-cache apache2-utils && htpasswd -nbB '$email' '$pass'")"

echo "saving..."
# to postfix
echo "$email ok" >>postfix.cont/data/conf/users.txt
# to dovecot
echo "$pwline" >>dovecot.cont/data/conf/passwd.txt
# to nginx
echo "$pwline" >>nginx.cont/data/passwd/mail.txt

echo "done!"
