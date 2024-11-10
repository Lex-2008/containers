Simple DynDNS server
====================

Currently it relies on upstream proxy server to authenticate users and set "X-Real-IP" and "X-Real-User" headers.

It then uses these two variables to construct a request to `nsupdate` utility to point `$HTTP_X_REAL_USER.dyn.shpakovsky.ru` DNS entry to the provided `$HTTP_X_REAL_IP` address on the `bind` server. All these values are hardcoded in the script.

To configure what users are allowed to access this server, configure upstream proxy.

Both IPv4 and IPv6 addresses are supported, but only one of them is set each time, so when using this service on a dual-stack system, remember to make **two** requests, updating both addresses, like this:

	wget -q6 --user=user1 --password=mypassword https://dyn.shpakovsky.ru/
	wget -q4 --user=user1 --password=mypassword https://dyn.shpakovsky.ru/

where dyn.shpakovsky.ru is the upstream proxy.

To pass desired IP address instead of relying on autodetection, add it as a query argument, like this:

	wget -q4 --user=user1 --password=mypassword https://dyn.shpakovsky.ru/?1.2.3.4
