# ensure list of postfix users matches list of dovecot users
# TODO: this must be part of adduser.sh script
#ls dovecot.cont/data/mail/ | sed 's/.*/& ok/' >postfix.cont/data/conf/users.txt

rm -f /tmp/emails.*

for user in `ls dovecot.cont/data/mail/`; do
	# get emails of all user's contacts:
	# * from squirrelmail addressbook
	cut -d'|' -f4 squirrelmail.cont/data/squirrelmail/$user.abook >/tmp/emails.txt
	# from baikal (note that for this to work, user must be registered
	# there with same email)
	sqlite3 baikal.cont/Specific/db/db.sqlite "select carddata from cards where addressbookid=(select addressbooks.id from addressbooks, principals on principals.uri=addressbooks.principaluri and principals.email='$user');" | sed '/^EMAIL/!d;s/.*://;s/\r//' >>/tmp/emails.txt
	sed 's/^\s*//;s/\s$//' /tmp/emails.txt | sort -u >/tmp/emails.$user

	# update sieve auto-trash filter, if user has it
	grep -qs '### auto-trash ###' dovecot.cont/data/sieve/$user.sieve || continue
	sed -i '/### auto-trash ###/q' dovecot.cont/data/sieve/$user.sieve
	cat /tmp/emails.$user | sed 's/.*/"&",/' >>dovecot.cont/data/sieve/$user.sieve
	echo '"x"]{ fileinto "Trash"; }' >>dovecot.cont/data/sieve/$user.sieve
done

rm /tmp/emails.txt
# add all emails of all contacts of all users to postfix whitelist
sort --merge -u /tmp/emails.* | sed 's/.*/& ok/' >postfix.cont/data/conf/known-senders.txt

rm /tmp/emails.*
