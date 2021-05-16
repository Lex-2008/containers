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
[p1]: http://www.plantuml.com/plantuml/uml/LP0zImGn48Rx-HLJAockNOvm81Q2M5a8QX4lepTS9XkJYPp_NjmrRj84yippllau57LPgmGuiISaIVgDdienSrAU8y3prIiQY_63usN28ffUuadRMW2AEYLCSz5tli3YeJ6saJLp_NHpVtVxy3ZQEzplANfhuG-WgLjojqRR2VxCidd1s8LCA1oKyhyrVz5nraqqjh49GrTNFYldJ44S1-WtQ_Tm-t4-LBAur3sw5oVy_I7efc-Epwxn0qLV9Vm0


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
