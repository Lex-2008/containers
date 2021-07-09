Containers
==========

How one user set them up

Picture worth 1k words
----------------------

![containers overview](containers.svg)

What can you see here:

* SMTP, HTTP, and HTTPS requests come to [nginx][] container - It manages all SSL stuff, including STARTTLS encryption layer for SMTP, and also serves static sites

* plaintext SMTP is forwarded to [Postfix][] server - together with XCLIENT which gives remote server information to Posfix

* Postfix uses [DKIM][] milter and forwards received emails to [dovecot][] via LMTP

* Also [SquirrelMail][] and [Baikal][] containers don't share address book, sadly

* This picture created with [PlantUML][p1]

[nginx]: nginx.cont/README.md
[Postfix]: postfix.cont/README.md
[dovecot]: dovecot.cont/README.md
[DKIM]: dkim.cont/README.md
[SquirrelMail]: squirrelmail.cont/README.md
[Baikal]: baikal.cont/README.md
[p1]: http://www.plantuml.com/plantuml/uml/NP2nIWGn48RxUOgfbHJNBaSu40j1h2m4jOYNqHjk9hicitA-lNXht5oQGFx_-oPXTiL2jba53Xm9IIVxnaXbdtao7XF0yzKhEe_fWzDfmA8slQI3rRC050j6E8t5tla4PmwTypLPdEkdc_kxsuV7Itg3sosbw3ty1UZcrTmiQdqX7bbNJfm_9mCgYr7-fyOlse-sWixNR41fnfNFcNCcqS02xGMTzB_l-dOaQ-XhZs-1Zq46_DrGiv46gsLjUsb7ASugFm00


Extra features
--------------

* Separate containers for SMTP security layer (ngnix) and message processing (Postfix)

* Separate containers for mail processing (Postfix) and storage (Dovecot)

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
This stuff is still in progress.

To terminate all running docker containers, run this command:

	docker ps -qa | xargs docker rm -f

Note that it will rip **all** your containers, not only those started here!
