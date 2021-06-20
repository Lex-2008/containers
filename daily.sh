cut -d'|' -f4 squirrelmail.cont/data/squirrelmail/*.abook | sed 's/.*/& ok/' >postfix.cont/data/conf/known-senders.txt
ls dovecot.cont/data/mail/ | sed 's/.*/& ok/' >postfix.cont/data/conf/users.txt
for user in `ls dovecot.cont/data/mail/`; do
	grep -q '### auto-trash ###' dovecot.cont/data/sieve/$user.sieve || continue
	sed -i '/### auto-trash ###/q' dovecot.cont/data/sieve/$user.sieve
	cut -d'|' -f4 squirrelmail.cont/data/squirrelmail/$user.abook | sed 's/.*/"&",/' >>dovecot.cont/data/sieve/$user.sieve
	echo '"x"]{ fileinto "Trash"; }' >>dovecot.cont/data/sieve/$user.sieve
done
