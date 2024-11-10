# Reindex given directory. Pass args:
# * Username (for example, "alexey")
# * IMAP folder name (for example, "INBOX")
# * optionaly, dirname (for example, "." for INBOX) - defaults to ".$IMAP_FOLDER_NAME"

username="$1"

if [ "$#" -eq 2 ]; then
	folder="$2"
	dirname=".$2"
elif [ "$#" -eq 3 ]; then
	folder="$2"
	dirname="$3"
fi

cd "data/mail/$username/Maildir/$dirname"

rm -f dovecot*                # remove all dovecot indexes
mkdir hid                     # make hidden directory
mv cur/* hid/                 # move all mails there
for file in $(ls -rt hid); do # walk through all mails, starting with oldest one
	mv hid/$file cur/         # move a file back
	docker exec -it dovecot dovecot -c /data/conf/dovecot.conf index -u "$username" "$folder"
done
rmdir hid                     # remove temporary directory
