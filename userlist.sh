for f in \
	postfix.cont/data/conf/users.txt \
	dovecot.cont/data/conf/passwd.txt \
	nginx.cont/data/passwd/mail.txt \
	nginx.cont/data/passwd/dyndns.txt \
; do
	echo "=== $f ==="
	cat "$f"
	echo
done

for d in \
	dovecot.cont/data/mail/ \
	squirrelmail.cont/data/squirrelmail/ \
; do
	echo "=== $d ==="
	ls -lA $d
	echo
done
