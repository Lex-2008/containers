Opinionated postfix
===================

Features
--------

* Receives email from XCLIENT-enabled proxy,
hence **no encryption needed**/supported.

* Forwards received email to LMTP client,
hence has no access to received email.

* Uses DKIM milter running in another VM/container.

* Verifies that local user exist (listed in a text file) before doing spam check.

* Does **not** perform spam-check against emails sent **from** addresses listed in `known_senders.txt` file,
thus your friends' mail will never go to spam!

* Does **not** perform spam-check against emails sent **to** addresses with `+` in them (like "alexey+facebook@example.com"),
thus those registration emails will never go to spam!

* uses one RBL for spam check.

Installation
------------

* Edit "mydomain" in `data/conf/main.cf` file

* Add `data/conf/users.txt` file with emails of users who are expected to receive emails via this server, using format like this:

		alexey@example.com ok

* Add `data/conf/known-senders.txt` file with emails whose senders should not be spam-checked, using same format.
