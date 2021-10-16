cd "${0%/*}"
mkdir -p data/zones data/logs
chown -R 100:101 data/zones
chown -f 100:101 data/logs data/logs/bind.log
