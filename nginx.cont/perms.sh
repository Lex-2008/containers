cd "${0%/*}"
chmod -R u=rX,go= data/cert
chown -R 100:101 data/passwd/
chmod -R u=rX,go= data/passwd
