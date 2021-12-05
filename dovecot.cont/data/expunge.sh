for user in `ls /data/mail/`; do
	test -f /data/mail/$user/expunge.txt || continue
	while read -r box time; do
		doveadm expunge -u $user mailbox $box savedbefore $time
	done </data/mail/$user/expunge.txt
done

