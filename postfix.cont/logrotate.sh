# TODO: this is probably not interesting for others
cd /containers/nginx.cont/data/public/alexey.shpakovsky.ru/en/
wget http://alexey.shpakovsky.ru/logshow/spam-emails.sh -O spam-emails-3.htm.new
cat spam-emails-3.htm >>spam-emails-3.htm.new
chown --reference=spam-emails-3.htm spam-emails-3.htm.new

docker exec -it postfix postfix -c /data/conf logrotate
