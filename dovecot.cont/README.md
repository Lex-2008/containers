Dovecot with LMTP and Sieve
===========================

Features
--------

* Exposes two ports for IMAP clients: 143, as usual, and 1433 for IMAP behind [haproxy PROXY][ha-proxy] protocol

* Receives mail from postfix via LMTP (port 26)

* Sorts received mail with Sieve

* Also sorts "sent" mail!

* Auto-deletes messages in Trash folder after 30 days

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

* Add users' sieve scripts to `data/sieve` directory, naming them `$email.sieve`.
For example, for user "test@example.com" create `data/sieve/test@example.com.sieve` file.

	For users who like messages from strangers (people not in their address book) to be sorted directly to trash,
	add this at the end of their sieve file:

		elsif not address :is "from" [
		### auto-trash ###

	and run the `daily.sh` script in parent dir.

	Note that `elsif` assumes there are other conditions above.

* Sent-mail-sorting sieve script is currently global.
Save it to `data/sieve/sent.sieve` file.

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
