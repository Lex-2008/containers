cd "${0%/*}"
mkdir -p data/keys data/certs data/logs
chown -f 1000:1000 data/logs data/logs/mail.log
