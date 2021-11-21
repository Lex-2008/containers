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

* Implements two [mail\_auth][] servers:
one which forwards only _non-authenticated_ SMTP connections to localhost:2525 backend,
and another one which performs an [HTTP Basic][] auth check against a list of username-password pairs.
Note that this is the same file used for basic auth for webmail interface in the bullet point above.

* Uses servers from above bullet point
to forward SMTP and IMAP connections to backend servers
(SMTP server should support [XCLIENT][] command,
IMAP server should support [HAproxy PROXY protocol][ha-proxy]).

* Failed SMTP/POP3/IMAP login attempts are logged to a separate file.

* Optionally, serves some static sites

[mail\_auth]: http://nginx.org/en/docs/mail/ngx_mail_auth_http_module.html#protocol
[HTTP Basic]: http://alexey.shpakovsky.ru/en/using-http-basic-auth-for-nginx-mail-auth-http-server.html
[XCLIENT]: http://nginx.org/en/docs/mail/ngx_mail_proxy_module.html#xclient
[ha-proxy]: http://www.haproxy.org/download/1.5/doc/proxy-protocol.txt

Installation
------------

* Replace "shpakovsky.ru" with your server name in `data/conf/nginx.conf` file.

* Generate SSL keys and put them in `data/cert` directory.
You can do it either manually, or use [dehydrated][] container.

[dehydrated]: dehydrated.cont/README.md

* (optionally) create `data/conf/servers.conf` file ([example provided][servers-ex]) and add your servers there.

[servers-ex]: data/conf/servers-example.conf

* Add `data/passwd/mail.txt` file with encrypted passwords to access SquirrelMail.
It's recommended to use passwd file from the dovecot container
and [Login Authentication][login] SquirrelMail plugin to automate login process.
While you could also have some separate username/password combination for extra security,
in current configuration it would break authentication with IMAP clients.
You can of course change the configuration to use different passwords for IMAP clients and webmail.

* Add `data/passwd/dyndns.txt` file with encrypted passwords to use [DynDNS][].

[login]: https://squirrelmail.org/plugin_view.php?id=34
[DynDNS]: ../dyndns.cont/README.md
