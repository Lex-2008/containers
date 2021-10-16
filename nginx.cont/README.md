nginx with mail and SSL
=======================

Features
--------

* Terminates https connections
and forwards plaintext http to backends

* Offers STARTTLS encryption for smtp connections
and forwards plaintext smtp to backend

* Uses same certificates for both items above

* Provides basic HTTP authentification
for some backend services

* Optionally, serves some static sites

Installation
------------

* Replace "shpakovsky.ru" with your server name in `data/conf/nginx.conf` file.

* Generate SSL keys and put them in `data/cert` directory.
Certificate generation _is left as exercise to the reader_,
but I just run [`dehydrated -c`][] manually and copy these two files:

		dehydrated/certs/shpakovsky.ru/fullchain.pem
		dehydrated/certs/shpakovsky.ru/privkey.pem

	Yes, I know it's supposed to be automated, but my DNS provider is not, and Let's Encrypt sends me reminder emails anyway.

[dehydrated]: https://dehydrated.io/

* (optionally) create `data/conf/servers.conf` file and add your servers there.
Example:

		server {
			listen              80;
			server_name         alexey.shpakovsky.ru;
			root                /data/public/alexey.shpakovsky.ru;
			access_log          /data/logs/alexey.log.gz combined gzip;
			location /.git/    { return 301 https://github.com/Lex-2008/Lex-2008.github.io/; }
		}

* Add `data/passwd/mail.txt` file with encrypted passwords to access SquirrelMail.
You can use passwd file from the dovecot container and [Login Authentication][login] SquirrelMail plugin to automate login process,
or some separate username/password combination for extra security.

* Add `data/passwd/dyndns.txt` file with encrypted passwords to use [DynDNS][].

[login]: https://squirrelmail.org/plugin_view.php?id=34
[DynDNS]: ../dyndns.cont/README.md
