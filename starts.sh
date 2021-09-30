cd /containers/

# mail
docker run -d -v $PWD/dovecot.cont/data:/data -p 127.0.0.1::26 -p 127.0.0.1::143 --name=dovecot dovecot
docker run -d -v $PWD/dkim.cont/data:/data -p 127.0.0.1::12301 --name=dkim dkim
docker run -d -v $PWD/postfix.cont/data:/data -p 127.0.0.1:2525:25 --link dovecot:dovecot --link dkim:dkim --name=postfix postfix
docker run -d -p 127.0.0.1::143 --link dovecot:dovecot -e SERVER_HOSTNAME=dovecot -e FORCE_TLS=no -e CACHE_EXPIRATION_TIME=606 --name=imapproxy cheungpat/imapproxy
# webs
docker run -d -v $PWD/baikal.cont/config:/var/www/baikal/config -v $PWD/baikal.cont/Specific:/var/www/baikal/Specific -p 127.0.0.1:8002:80 --name=baikal ckulka/baikal:nginx
docker run -d -v $PWD/squirrelmail.cont/data:/data -p 127.0.0.1:8001:80 --link imapproxy:imapproxy --link postfix:postfix --link baikal:baikal --name=squirrelmail squirrelmail
docker run -d -v $PWD/logshow.cont/data:/data -v $PWD/nginx.cont/data/logs:/nginx-logs -v $PWD/postfix.cont/data/logs:/postfix-logs -p 127.0.0.1:8003:8000 --name=logshow logshow

# frontend
docker run -d -v $PWD/nginx.cont/data:/data --net=host --name=nginx nginx

