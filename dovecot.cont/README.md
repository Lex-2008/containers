Dovecot with LMTP and Sieve
===========================

Features
--------

* Receive mail from postfix via LMTP

* mail sorting via Sieve

* Also "sent" mail sorting

* List of users with passwords stored in single file

Installation
------------

* Add users to `data/conf/passwd.txt` file, in format like this:

	{email}:{encrypted-password}

To encrypt the password, you can use `openssl passwd` command.

For example, to add user with email "test@example.com" and password "Tr0ub@dur", you can execute this line:

	$ echo "test@example.com:`openssl passwd Tr0ub@dur`" | tee data/conf/passwd.txt
	Warning: truncating password to 8 characters
	test@example.com:k3Nn97/2DWock

* Add users' sieve scripts to `data/sieve` directory, naming them `$email.sieve`.
For example, for user "test@example.com", create file `data/sieve/test@example.com.sieve`.

* Sent-mails sieve script is currently global.
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

Used sources
------------

* <https://wiki.dovecot.org/HowTo/Virtual+Postfix+Dspam+Dovecot>
* <https://doc.dovecot.org/configuration_manual/protocols/lmtp_server/>
* <https://doc.dovecot.org/configuration_manual/howto/postfix_dovecot_lmtp/>
* <https://doc.dovecot.org/configuration_manual/authentication/passwd_file/>
