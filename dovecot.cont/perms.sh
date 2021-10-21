cd "${0%/*}"
mkdir -p data/logs data/sieve data/mail
test -f data/conf/passwd.txt || touch data/conf/passwd.txt
chown 90:101 data/conf/passwd.txt
chmod u=r,go= data/conf/passwd.txt
chown -R 1000:1000 data/sieve data/mail
