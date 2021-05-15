FROM alpine

RUN apk add --no-cache lighttpd php7-cgi php7-gettext php7-session php7-mbstring

RUN wget https://squirrelmail.org/countdl.php?fileurl=http%3A%2F%2Fsnapshots.squirrelmail.org%2Fsquirrelmail-$(date +%Y%m%d)_0200-SVN.stable.tar.bz2 -O /tmp/squirrelmail.tar.bz2 && \
    tar -C / -xf /tmp/squirrelmail.tar.bz2 && \
    rm -rf /tmp/squirrelmail.tar.bz2 /squirrelmail.stable/squirrelmail/config /squirrelmail.stable/squirrelmail/plugins && \
    ln -s /data/config /squirrelmail.stable/squirrelmail && \
    ln -s /data/plugins /squirrelmail.stable/squirrelmail && \
    mkdir -p /var/local/squirrelmail/attach && \
    ln -s /data/squirrelmail /var/local/squirrelmail/data

EXPOSE 8000
USER 1000:1000
CMD ["lighttpd", "-D", "-f", "/data/lighttpd.conf"]
