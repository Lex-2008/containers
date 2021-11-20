FROM alpine

RUN apk add --no-cache postfix && \
    newaliases && \
    postconf -M smtp/inet | sed 's/^smtp/26/;s/$/ -o smtpd_milters=/' >>/etc/postfix/master.cf

EXPOSE 25 26

CMD [ "postfix", "-c", "/data/conf", "start-fg" ]
