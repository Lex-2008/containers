Containers
==========

How one user set them up

Intro
-----

Containers are nice:

* They force you to be careful about storing your **configuration**:
instead of modifying vendored config files in various places,
you should either "bake" your config into image
(thus, likely, documenting all changes in Dockerfile),
or expose few files/dirs to the container
(thus, likely, limiting your config to only few files).

* They are good for **portability**:
if you rented a cloud VM ~10 years ago and it's less than supported time for the OS you installed at that time,
then you have to either upgrade it to new version
(which is, well, risky),
or migrate your config to a new clean installed version,
and what did I tell you about 
modifying vendored config files in the bullet point above?

* They are good for **security**:
based on Linux security features (like chroot),
they might be not as secure as separate VMs running on the same host
(although this is questionable),
and definitely not as secure as your own physical hardware
behind a bullet-proof door,
but still better than nothing.

	After all, why let your world-exposed SMTP server access the mail you've already received?
	Or why not keep your HTTPS certificates separate from PHP scripts you downloaded from Internet,
	which might (or might not) contain vulnerabilities, PHP shells, etc?
	Or from your e-mails?

	Of course, one might say that containers are not _made for_ security,
	but I will answer that no wall is impenetrable, and extra layer of security is better than lack of it.


Picture worth 1k words
----------------------

![containers overview](containers.svg)

What can you see here:

* IMAP, SMTP, HTTP, and HTTPS requests come to [nginx][] container - It manages all SSL stuff, including STARTTLS encryption layer for SMTP, and also serves static sites.
Note that it's the only container directly exposed to Internet and having permanent to the SSL certificates.

* Plaintext SMTP is forwarded to [Postfix][] server - together with [XCLIENT][] command which gives Postfix information about remote server.

* Postfix uses [DKIM][] milter and forwards received emails to [dovecot][] via LMTP.

* Other mail-related backend servers are [SquirrelMail][] for webmail and [Baikal][] for calendar/address book sync, both of which are implemented in plain PHP.
SquirrelMail uses [CardDav addressbook plugin][abook_carddav] to access Baikal addressbook.
Note that for [performance reasons][alpine-php-perf], they use containers based on Debian, not Alpine.

* SquirrelMail talks to Dovecot via [imapproxy][] which caches IMAP connections.
While it doesn't give any performance benefits, it greatly decreases noise in Dovecot logs.

* DNS requests come to the [bind][] container which serves as _authoritative_ DNS server for _dyn.shpakovsky.ru_ zone.

* Some HTTP requests are forwarded from nginx to [dyndns][] container which uses `nsupdate` to change the dynamic zone in the bind container.

* A manually-started [dehydrated][] container uses ACME in DNS mode to issue Let's Encrypt certificates.

* Also, a special [logshow][] backend server gives you insights into nginx and postfix logs - for realtime updates of lists of [spamers][] and [hackers][].

* An [opendkim-testmsg][] backend server provides a [DKIM signature online test][opendkim-testmsg-online].

* This picture was created with [PlantUML][p1].

[nginx]: nginx.cont/README.md
[Postfix]: postfix.cont/README.md
[XCLIENT]: http://www.postfix.org/XCLIENT_README.html
[dovecot]: dovecot.cont/README.md
[DKIM]: dkim.cont/README.md
[SquirrelMail]: squirrelmail.cont/README.md
[Baikal]: baikal.cont/README.md
[abook_carddav]: https://github.com/Lex-2008/abook_carddav
[alpine-php-perf]: http://alexey.shpakovsky.ru/en/when-not-to-use-alpine.html
[imapproxy]: https://hub.docker.com/r/cheungpat/imapproxy
[bind]: bind.cont/README.md
[dyndns]: dyndns.cont/README.md
[dehydrated]: dehydrated.cont/README.md
[logshow]: logshow.cont/data/html/
[opendkim-testmsg]: opendkim-testmsg.cont/README.md
[opendkim-testmsg-online]: https://opendkim-testmsg.shpakovsky.ru/
[spamers]: http://alexey.shpakovsky.ru/en/spam-emails.html
[hackers]: http://alexey.shpakovsky.ru/en/login-attempts.html
[p1]: http://www.plantuml.com/plantuml/uml/TL8zJyCm4DtzAqwTW3O3QrHLHOW1gMAW6P20mTIciUeFOr-W-VVOpSUraReuT--UtxFUPHsH1soCPhKI4gJns8AGSHUKH-KiO-ztdr0KAx1xPOybr8X-SJhZuiCgmrENpzn5WnvkvjlguRMgDjjRklobh2X1sCXECYTCj3O1dIBh6YYQaMnZumL7oLZ4z07l8dwh8maCI0dPT_xsk7b-UgaksVUmN4ehLYlM0vt3CEsk3WxYe0pnTE9bf0IZDCemijolt3aaOkBrM0awoT4B2Ky9ZJQvzi4TMpPMrydnfr4XI6suqkoyWK9F8vZCqtWqw4Kl2IbfhWvSzokWPv_Jyf0YcZalRKwbG1dHnFqCU8G1x356KjSSjDl7slrDyQdIfRcGTIj2gWIjbR0kaCc_G-DkyTIdtVETaMoTT1gZ_m40


Extra features
--------------

* Separate containers for SMTP security layer (ngnix) and message processing (Postfix)

* Separate containers for mail processing (Postfix) and mail storage (Dovecot)

With periodically running [daily.sh](daily.sh):

* mail from addresses listed in SquirrelMail address books is excluded from spam check

* list of dovecot users is synced to postfix (mail to non-existing local users promptly discarded)

* mail from addresses not listed in user's SquirrelMail address book sorted directly to trash (optionally)


Installation
------------

* (optionally) look through all dockerfiles and edit them to your taste

* Run `builds.sh` to build all containers

* Look through all directories, read all READMEs, edit all necessary files,
optionally run `daily.sh` to sync configs.

* Run `starts.sh` to start all containers

* (optionally) run `docker ps -a` to confirm that all containers are running

Usage
-----

Some directories have `reload.sh` and `logrotate.sh` files to reload config files and rotate logs for relevant services.
`logrotate.sh` file in the root of this repo will call `logrotate.sh` files in all directories.

To terminate all running docker containers, run this command:

	docker ps -qa | xargs docker rm -f

Note that it will rip **all** your containers, not only those started here!
