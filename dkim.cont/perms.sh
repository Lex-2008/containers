cd "${0%/*}"
mkdir -p data/key data/logs
chmod -R u=rX,go= data/key
chown -f 102:102 data/logs data/logs/mail.log
