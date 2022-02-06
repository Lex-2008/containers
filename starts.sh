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
docker run -d -v $PWD/squirrelmail.cont/data:/data -p 127.0.0.1:8001:80 --link imapproxy:imapproxy --link postfix:postfix --link baikal:baikal --name=squirrelmail squirrelmail
docker run -d -v $PWD/logshow.cont/data:/data -v $PWD/nginx.cont/data/logs:/nginx-logs -v $PWD/postfix.cont/data/logs:/postfix-logs -p 127.0.0.1:8003:8000 --name=logshow logshow
docker run -d -v $PWD/dyndns.cont/data:/data -v $PWD/bind.cont/data/key.conf:/key.conf --link bind:bind -p 127.0.0.1:8004:8000 --name=dyndns dyndns
docker run -d -v $PWD/opendkim-testmsg.cont/data:/data -p 127.0.0.1:8005:8000 --name=opendkim-testmsg opendkim-testmsg
docker run -d -v $PWD/calc.cont/data:/data -p 127.0.0.1:8006:8000 --name=calc calc
docker run -d -v $PWD/dropbox.cont/data:/data -p 127.0.0.1:8007:8000 --name=dropbox dropbox

# gemini
docker run -d -v $PWD/gemini.cont/data:/data -p 127.0.0.1:1966:1234 --user 1000:1000 --name=gemini alpine nc -lk -p 1234 -e /data/server.sh

# frontend
docker run -d -v $PWD/nginx.cont/data:/data --net=host --name=nginx nginx

