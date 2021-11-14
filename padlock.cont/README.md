S/MIME signing SMTP proxy server
================================

This SMTP server listens on port 1025, signs all incoming messages
(to which it has S/MIME key-certificate pairs),
and forwards them to an upstream SMTP server.

At the moment, only a single upstream server is supported,
which is currently hardcoded to be gmail MX server,
so as of writing it's useful only for messages sent _to_ a `@gmail.com` address.
That's fine for me, but PRs fixing this are welcome!

Installation
------------

Assuming you're using [Actalis][a] free S/MIME certificates for `user@example.com` email,
they send you a file called `PKCS12_Credential_user@example.com.pfx` and show a password for it.
You need to decrypt and split it into 4 parts.

[a]: https://extrassl.actalis.it/portal/uapub/freemail?lang=en


* First, run this command:

		openssl pkcs12 -in PKCS12_Credential_*.pfx -info -nodes

	After providing your password, you will see an output like this
	(long sequences of base64 gibberish shortened):

		MAC: sha1, Iteration 102400
		MAC length: 20, salt length: 20
		PKCS7 Data
		Shrouded Keybag: pbeWithSHA1And3-KeyTripleDES-CBC, Iteration 51200
		Bag Attributes
		    localKeyID: 6E 14 EB CD E8 72 EF 19 6F 68 D5 59 B9 77 FD E1 FE 2D 8A C9 
		    friendlyName: user@example.com
		Key Attributes: <No Attributes>
		-----BEGIN PRIVATE KEY-----
		bEHeNq68nxa/K2TAq2SoMDurGDeJYBNAYiFL8DJ2i4J7uXR7gL7Ac1Ao+y48/IXV
		...
		G7sztqA9XDQv6W+2roVlkQ==
		-----END PRIVATE KEY-----
		PKCS7 Encrypted data: pbeWithSHA1And40BitRC2-CBC, Iteration 51200
		Certificate bag
		Bag Attributes
		    localKeyID: 6E 14 EB CD E8 72 EF 19 6F 68 D5 59 B9 77 FD E1 FE 2D 8A C9 
		    friendlyName: user@example.com
		subject=CN = user@example.com

		issuer=C = IT, ST = Bergamo, L = Ponte San Pietro, O = Actalis S.p.A., CN = Actalis Client Authentication CA G3

		-----BEGIN CERTIFICATE-----
		clIWZ6PJ6L44k8UH+PckivhAOVmIgtxhpltr4CGrb29Z5y7h5dK1wV8PZWpgqcNs
		...
		LaayQOjHRhXJ8Q//g/sqdw==
		-----END CERTIFICATE-----
		Certificate bag
		Bag Attributes
		    friendlyName: Actalis Client Authentication CA G3
		subject=C = IT, ST = Bergamo, L = Ponte San Pietro, O = Actalis S.p.A., CN = Actalis Client Authentication CA G3

		issuer=C = IT, L = Milan, O = Actalis S.p.A./03358520967, CN = Actalis Authentication Root CA

		-----BEGIN CERTIFICATE-----
		MIIHbTCCBVWgAwIBAgIQFxA+3j2KHLXKBlGT58pDazANBgkqhkiG9w0BAQsFADBr
		...
		nMQBstsymBBgdEKO+tTHHCMnJQVvZn7jRQ20wXgxMrvN
		-----END CERTIFICATE-----
		Certificate bag
		Bag Attributes
		    friendlyName: Actalis Authentication Root CA
		subject=C = IT, L = Milan, O = Actalis S.p.A./03358520967, CN = Actalis Authentication Root CA

		issuer=C = IT, L = Milan, O = Actalis S.p.A./03358520967, CN = Actalis Authentication Root CA

		-----BEGIN CERTIFICATE-----
		MIIFuzCCA6OgAwIBAgIIVwoRl0LE48wwDQYJKoZIhvcNAQELBQAwazELMAkGA1UE
		...
		LnPqZih4zR0Uv6CPLy64Lo7yFIrM6bV8+2ydDKXhlg==
		-----END CERTIFICATE-----

* The first gibberish base64-encoded data between _and including_ `-----BEGIN PRIVATE KEY-----` and `-----END PRIVATE KEY-----` is your key.
	Save it to `data/keys/user@example.com.key` file (replace `user@example.com` with your actual email address):

		cat >data/keys/user@example.com.key
		-----BEGIN PRIVATE KEY-----
		bEHeNq68nxa/K2TAq2SoMDurGDeJYBNAYiFL8DJ2i4J7uXR7gL7Ac1Ao+y48/IXV
		...
		G7sztqA9XDQv6W+2roVlkQ==
		-----END PRIVATE KEY-----
		^D

* Then, three certificates follow.
	You can distinguish them by "subject" and "issuer" lines above
	`-----BEGIN CERTIFICATE-----` ... `-----END CERTIFICATE-----` blocks of base64.

	First one is the certificate specific for your email address and goes to appropriately-named file:

		cat >data/certs/user@example.com.crt
		-----BEGIN CERTIFICATE-----
		clIWZ6PJ6L44k8UH+PckivhAOVmIgtxhpltr4CGrb29Z5y7h5dK1wV8PZWpgqcNs
		...
		LaayQOjHRhXJ8Q//g/sqdw==
		-----END CERTIFICATE-----
		^D

* Second one is so-called _intermediate_ certificate, which stands between _root_ certificate which everyone trusts,
	and your specific cert:

		cat >data/certs/intermediate.crt
		-----BEGIN CERTIFICATE-----
		MIIHbTCCBVWgAwIBAgIQFxA+3j2KHLXKBlGT58pDazANBgkqhkiG9w0BAQsFADBr
		...
		nMQBstsymBBgdEKO+tTHHCMnJQVvZn7jRQ20wXgxMrvN
		-----END CERTIFICATE-----
		^D

	Note that at this moment, this script supports only a single intermediate certificate.
	That's fine for me, but if you need more - feel free to improve it!

* Third certificate is the _root_ one, which is _self-signed_
	(you can see that "issuer" and "subject" lines are the same for it),
	and theoretically everyone should already have it.
	But we still include it:

		cat >data/certs/root.crt
		-----BEGIN CERTIFICATE-----
		MIIFuzCCA6OgAwIBAgIIVwoRl0LE48wwDQYJKoZIhvcNAQELBQAwazELMAkGA1UE
		...
		LnPqZih4zR0Uv6CPLy64Lo7yFIrM6bV8+2ydDKXhlg==
		-----END CERTIFICATE-----
		^D

Usage
-----

Just connect to port 1025 and talk SMTP :)

Alternatevly, if you wish to enable S/MIME for selected recepients
(as of now, gmail only, see note above),
you can use transport\_maps feature in postfix:

	$ grep transport_maps /postfix/conf/main.cf
	transport_maps = texthash:/postfix/conf/transport_maps.txt
	$ cat /postfix/conf/transport_maps.txt
	user@gmail.com smtp:[padlock]:1025


Security note
-------------

Note that since signing key is stored on the server, this does **not** add any extra security compared to DKIM signature.

The only purpose of this server is to satisfy those email clients/servers/users who can't/don't check/show DKIM signatures, but have an option to check/show S/MIME ones.

