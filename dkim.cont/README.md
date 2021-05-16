Trivial opendkim container
==========================

Installation
------------

* Edit the `data/conf/opendkim.conf` file to specify your domain name instead of shpakovsky.ru

* (optionally) edit other settings in that file as you like, use [opendkim.conf man page][man-conf] for more info

[man-conf]: http://www.opendkim.org/opendkim.conf.5.html

* (optionally) edit the `data/conf/bodylength.txt` to specify domains of mailing lists (where you send mails to),
which might append text at the end of your messages (read more about bodylength to understand this).

* Generate new key (specify your domain instead of shpakovsky.ru):

		# enter the container
		docker run --rm -it dkim sh

		# generate the key
		cd /data/key
		opendkim-genkey -s postfix -d shpakovsky.ru

* Add DKIM DNS record - its content is in `data/key/postfix.txt` file

* (optionally) also add DMARC and SPF records.

* (optionally) test that your email is properly DKIM-signed.

In case of problems, check [this][do] awesome DKIM guide from Digital Ocean.

[do]: https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-dkim-with-postfix-on-debian-wheezy

Usage
-----

To use this milter in your postfix, add this line to your `main.cf` file:

	smtpd_milters = inet:dkim:12301

where `dkim` is IP address or hostname of VM or container where this milter is running,
and 12301 is port number from `data/conf/opendkim.conf` file.
