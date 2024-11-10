cd /containers/

docker exec bind rndc -p9533 sync -clean
docker exec dovecot sh /data/expunge.sh
test -f gemini.cont/data/votes/tokens.txt && mv gemini.cont/data/votes/tokens.txt gemini.cont/data/votes/yestertokens.txt || rm gemini.cont/data/votes/yestertokens.txt
docker run --rm -v $PWD/ancha.cont/data:/data -v $PWD/nginx.cont/data/public/ancha-times.shpakovsky.ru:/out ancha >ancha.cont/last.log 2>&1

rm -f /tmp/emails.*

for user in `ls dovecot.cont/data/mail/`; do
	# get emails of all user's contacts:
	# from squirrelmail addressbook
	test -f squirrelmail.cont/data/squirrelmail/$user.abook || continue
	cut -d'|' -f4 squirrelmail.cont/data/squirrelmail/$user.abook >/tmp/emails.txt
	# from baikal (note that for this to work, user must be registered
	# there with same email)
	sqlite3 baikal.cont/Specific/db/db.sqlite "select carddata from cards where addressbookid=(select addressbooks.id from addressbooks, principals on principals.uri=addressbooks.principaluri and principals.email='$user');" | sed '/^EMAIL/!d;s/.*://;s/\r//' >>/tmp/emails.txt
	sed 's/^\s*//;s/\s$//' /tmp/emails.txt | sort -u >/tmp/emails.$user

	# update sieve contacts filter, if user has it
	grep -qs '### contacts begin ###' dovecot.cont/data/mail/$user/in.sieve || continue
	sed '/### contacts begin ###/,/### contacts end ###/{/### contacts /!d};/### contacts begin ###/ r'/tmp/emails.$user

done

rm /tmp/emails.txt
# add all emails of all contacts of all users to postfix whitelist
sort --merge -u /tmp/emails.* | sed 's/.*/& ok/' >postfix.cont/data/conf/known-senders.txt

rm /tmp/emails.*
