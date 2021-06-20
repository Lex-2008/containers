cd /containers/

# mail
docker run -d -v $PWD/dovecot.cont/data:/data -p 127.0.0.1::26 -p 127.0.0.1::143 --name=dovecot dovecot
docker run -d -v $PWD/dkim.cont/data:/data -p 127.0.0.1::12301 --name=dkim dkim
docker run -d -v $PWD/postfix.cont/data:/data -p 127.0.0.1:2525:25 --link dovecot:dovecot --link dkim:dkim --name=postfix postfix
# webs
docker run -d -v $PWD/baikal.cont/data:/data -p 127.0.0.1:8002:8000 --name=baikal baikal
docker run -d -v $PWD/squirrelmail.cont/data:/data -p 127.0.0.1:8001:8000 --link dovecot:dovecot --link postfix:postfix --link baikal:baikal --name=squirrelmail squirrelmail

# frontend
docker run -d -v $PWD/nginx.cont/data:/data --net=host --name=nginx nginx

