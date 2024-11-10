Dovecot with LMTP and Sieve
===========================

Features
--------

* Exposes two ports for IMAP clients: 143, as usual, and 1433 for IMAP behind [haproxy PROXY][ha-proxy] protocol

* Receives mail from postfix via LMTP (port 26)

* Sorts received mail with Sieve

* Also sorts "sent" mail!

* considers both `+` and `-` as "recipient delimiters",
so you can use both "user+site@example.com" and "user-site@example.com" for registering on websites -
they both will be delivered to "user@example.com", and you can easily track who leaked your email.

* List of users with passwords stored in single file

[ha-proxy]: https://wiki2.dovecot.org/HAProxy

Installation
------------

* Add users to `data/conf/passwd.txt` file, in format like this:

		{email}:{encrypted-password}

	To encrypt the password you can use `openssl passwd` command.
	For example, to add user with email "test@example.com" and password "Tr0ub@dur", you can execute this line:

		$ echo "test@example.com:`openssl passwd Tr0ub@dur`" | tee -a data/conf/passwd.txt
		Warning: truncating password to 8 characters
		test@example.com:k3Nn97/2DWock

* Create maildirs for them, like this:

		mkdir -p data/test@example.com/Maildir

* Add users' sieve scripts next to the above Maildir directory,
naming them `in.sieve` for filtering incoming email
and `out.sieve` for filtering outgoing email.

	For example, for user "test@example.com" create `data/mail/test@example.com/in.sieve` file.

	For users who like messages from strangers (people not in their address book) to be sorted directly to trash,
	add this at the end of their sieve file:

		elsif address :is "from" [
		### contacts begin ###
		### contacts end ###
		"x"]{ keep; }
		else { fileinto "Trash"; }

	and run the `daily.sh` script in parent dir.

	Note that `elsif` assumes there are other conditions above.
	Also note that you might have other `elsif` blocks before final `else` -
	in case you want to do something extra sorting for messages-from-non-friends,
	for example based on "+" tags.

* To auto-delete (expunge) old messages (say, from Trash and spam),
create `expunge.txt` files next to each of the user's Maildir directories,
with format like this:

		Spam 7d
		Trash 30d

	to auto-delete messages from Spam folder 7 days, and from Trash - 30 days
	after they were received.

	Deletion itself is done by `data/expunge.sh` script which
	should be run inside container every day.
	You can add `daily.sh` from parent dir to your host crontab.

Usage
-----

To deliver email to this dovecot from your postfix, add this to your `main.cf` file:

	# disable local delivery
	mydestination=

	# deliver to dovecot container
	virtual_mailbox_domains = $mydomain
	virtual_transport = lmtp:inet:dovecot:26
	lmtp_host_lookup = native

where `dkim` is IP address or hostname of VM or container where this milter is running,
and `lmtp_host_lookup = native` might be needed if IP address is stored in `/etc/hosts` file.

To read email from mail client, just use it as a normal IMAP server.

If IMAP server is behind proxy, use HAproxy [PROXY][ha-proxy] protocol and port 1433

Used sources
------------

* <https://wiki.dovecot.org/HowTo/Virtual+Postfix+Dspam+Dovecot>
* <https://doc.dovecot.org/configuration_manual/protocols/lmtp_server/>
* <https://doc.dovecot.org/configuration_manual/howto/postfix_dovecot_lmtp/>
* <https://doc.dovecot.org/configuration_manual/authentication/passwd_file/>
* <https://dovecot.org/pipermail/dovecot/2015-October/102236.html>
* <https://wiki2.dovecot.org/HAProxy>
