BIND authoritative DNS server
=============================

With an option for remote (dynamic) DNS update.

Configuration
-------------

* Run `ddns-confgen` and save its output in `data/key.conf` file.
Afterwards, you can use the same key file with `nsupdate` to modify DNS entries remotely.

* Edit `data/named.conf` file according to your preferences.
It currently requires `data/zones/dyn.zone` file, and there's an `*.example` file next to it.
