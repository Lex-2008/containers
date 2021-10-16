cd "${0%/*}"
mkdir -p data/logs
chown 90:101 data/conf/passwd.txt
chmod u=r,go= data/conf/passwd.txt
