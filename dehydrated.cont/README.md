Dehydrated server for Lets Encrypt certs via BIND server
========================================================

Based on [this example][t].

In current configuration, it can issue certificates for any domains which point their `_acme-challenge` subdomains as CNAME to `_acme-challenge.dyn.shpakovsky.ru` (and are listed in domains.txt).

[t]: https://github.com/dehydrated-io/dehydrated/wiki/example-dns-01-nsupdate-script

Installation
------------

1. Clone [dehydrated][d] repo to `data` subdir

[d]: https://github.com/dehydrated-io/dehydrated

2. in the same dir, create `domains.txt` file with list of all domains, like this:

		shpakovsky.ru *.shpakovsky.ru

2. in the same dir, create `config` file like this:

		CONTACT_EMAIL=alexey+dehydrated@shpakovsky.ru
		#CA="https://acme-staging-v02.api.letsencrypt.org/directory"
		CHALLENGETYPE=dns-01
		HOOK=/data/hook.sh

2. in the same dir, create `hook.sh` file like this:

		#!/usr/bin/env bash

		# based on:
		#
		# Example how to deploy a DNS challenge using nsupdate
		#
		# from https://github.com/dehydrated-io/dehydrated/wiki/example-dns-01-nsupdate-script

		set -e
		set -u
		set -o pipefail

		NSUPDATE="nsupdate -k /key.conf"

		zone="dyn.shpakovsky.ru"

		ns_command="server bind 5353
		zone $zone
		update %s _acme-challenge.$zone 1 in TXT \"%s\"
		send"

		case "$1" in
		    "deploy_challenge")
			printf "$ns_command" add "${4}" | $NSUPDATE
			;;
		    "clean_challenge")
			printf "$ns_command" delete "${4}" | $NSUPDATE
			;;
		    "deploy_cert")
			# let the caller script know they should do it
			touch /data/deploy_cert
			;;
		esac

		exit 0


Usage
-----

Run `run.sh` manually or via cron.
