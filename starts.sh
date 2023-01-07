cd /containers/

# bind
docker run -d -v $PWD/bind.cont/data:/data -p 53:5353 -p 53:5353/udp --name=bind bind
# mail
docker run -d -v $PWD/dovecot.cont/data:/data -p 127.0.0.1::26 -p 127.0.0.1::143 -p 127.0.0.1:1433:1433 --name=dovecot dovecot
docker run -d -v $PWD/dkim.cont/data:/data -p 127.0.0.1::12301 --name=dkim dkim
docker run -d -v $PWD/padlock.cont/data:/data -p 127.0.0.1::1025 --name=padlock padlock
docker run -d -v $PWD/postfix.cont/data:/data -p 127.0.0.1:2525:26 --link dovecot:dovecot --link dkim:dkim --link padlock:padlock --name=postfix postfix
docker run -d -p 127.0.0.1::143 --link dovecot:dovecot -e SERVER_HOSTNAME=dovecot -e FORCE_TLS=no -e CACHE_EXPIRATION_TIME=606 --name=imapproxy cheungpat/imapproxy
# webs
docker run -d -v $PWD/baikal.cont/config:/var/www/baikal/config -v $PWD/baikal.cont/Specific:/var/www/baikal/Specific -p 127.0.0.1:8002:80 --name=baikal ckulka/baikal:nginx
docker run -d -v $PWD/squirrelmail.cont/data:/data -p 127.0.0.1:8001:8000 --link imapproxy:imapproxy --link postfix:postfix --link baikal:baikal --name=squirrelmail squirrelmail
docker run -d -v $PWD/logshow.cont/data:/data -v $PWD/nginx.cont/data/logs:/nginx-logs -v $PWD/postfix.cont/data/logs:/postfix-logs -p 127.0.0.1:8003:8000 --name=logshow logshow
docker run -d -v $PWD/dyndns.cont/data:/data -v $PWD/bind.cont/data/key.conf:/key.conf --link bind:bind -p 127.0.0.1:8004:8000 --name=dyndns dyndns
docker run -d -v $PWD/opendkim-testmsg.cont/data:/data -p 127.0.0.1:8005:8000 --name=opendkim-testmsg opendkim-testmsg
docker run -d -v $PWD/calc.cont/data:/data -p 127.0.0.1:8006:8000 --name=calc calc
docker run -d -v $PWD/backup3-demo.cont/data:/data -p 127.0.0.1:8009:8000 --name=backup3-demo backup3-demo

# docker run -d -v $PWD/gotosocial.cont/data:/gotosocial/storage -p 127.0.0.1:8010:8080 -e GTS_LANDING_PAGE_USER=alexey -e GTS_HOST=gts.shpakovsky.ru -e GTS_ACCOUNT_DOMAIN=shpakovsky.ru -e GTS_TRUSTED_PROXIES=172.17.0.0/16 -e GTS_DB_TYPE=sqlite -e GTS_DB_ADDRESS=/gotosocial/storage/sqlite.db -e GTS_SMTP_HOST=postfix -e GTS_SMTP_PORT=25 -e GTS_SMTP_FROM=gotosocial@shpakovsky.ru --link=postfix:postfix --name=gotosocial superseriousbusiness/gotosocial

docker run -d -v $PWD/microblog.cont/microblog.pub:/app -p 127.0.0.1:8011:8000 --name microblog microblog
# docker run -d -v $PWD/microblog.cont/microblog.test:/app -p 127.0.0.1:8012:8000 --name microblogtest microblog

# gemini
docker run -d -v $PWD/gemini.cont/data:/data -p 127.0.0.1:1966:1234 --name=gemini gemini nc -lk -p 1234 -e /data/server.sh
docker run -d -v $PWD/ggstproxy.cont/data:/data -p 127.0.0.1:8008:8000 --link gemini:gemini --name=ggstproxy ggstproxy

# frontend
docker run -d -v $PWD/nginx.cont/data:/data --net=host --name=nginx nginx

