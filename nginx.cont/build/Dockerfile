FROM alpine

RUN apk add --no-cache nginx nginx-mod-mail nginx-mod-http-set-misc nginx-mod-stream

EXPOSE 25 80 443

CMD [ "nginx", "-c", "/data/conf/nginx.conf" ]
