FROM alpine:latest
RUN apk add --no-cache lighttpd php7-cgi php7-gettext php7-session patch php7-iconv php7-json php7-mbstring php7-xmlreader php7-xmlwriter php7-openssl curl

#ENV branch=devel \
ENV branch=stable \
    memory_limit=1700M \
    post_max_size=1600M \
    upload_max_filesize=1500M

RUN curl -L https://squirrelmail.org/countdl.php?fileurl=http%3A%2F%2Fsnapshots.squirrelmail.org%2Fsquirrelmail-$(date +%Y%m%d)_0200-SVN.$branch.tar.bz2 >/tmp/squirrelmail.tar.bz2 && \
#RUN wget https://altushost-swe.dl.sourceforge.net/project/squirrelmail/stable/$version/squirrelmail-webmail-$version.tar.bz2 -O /tmp/squirrelmail.tar.bz2 && \
    # extract the file and move the actual code to /squirrelmail dir
    tar -C / -xf /tmp/squirrelmail.tar.bz2 && \
    test -d /squirrelmail.stable/squirrelmail && mv /squirrelmail.stable/squirrelmail /; \
    test -d /squirrelmail.devel && mv /squirrelmail.devel /squirrelmail; \
    test -d /squirrelmail-webmail-$version && mv /squirrelmail-webmail-$version /squirrelmail; \
    # backup vendored config
    mv /squirrelmail/config /squirrelmail/config.bak && \
    mv /squirrelmail/plugins /squirrelmail/plugins.bak && \
    # apply local config
    ln -s /data/config /squirrelmail && \
    ln -s /data/plugins /squirrelmail && \
    mkdir -p /var/local/squirrelmail/attach && \
    chown 1000:1000 /var/local/squirrelmail/attach && \
    ln -s /data/squirrelmail /var/local/squirrelmail/data && \
    sed -i "/memory_limit/s/=.*/=$memory_limit/;/post_max_size/s/=.*/=$post_max_size/;/upload_max_filesize/s/=.*/=$upload_max_filesize/;" /etc/php7/php.ini

EXPOSE 8000
USER 1000:1000
CMD ["lighttpd", "-D", "-f", "/data/lighttpd.conf"]
