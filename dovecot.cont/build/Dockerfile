FROM alpine

RUN apk add --no-cache dovecot dovecot-lmtpd dovecot-pigeonhole-plugin

RUN adduser -HD vmail

EXPOSE 26 143

CMD [ "dovecot", "-F", "-c", "/data/conf/dovecot.conf" ]
