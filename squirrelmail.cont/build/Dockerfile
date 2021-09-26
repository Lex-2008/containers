FROM php:7-apache

#ENV branch=devel \
ENV branch=stable \
    memory_limit=1700M \
    post_max_size=1600M \
    upload_max_filesize=1500M \
    max_execution_time=300

RUN curl -L https://squirrelmail.org/countdl.php?fileurl=http%3A%2F%2Fsnapshots.squirrelmail.org%2Fsquirrelmail-$(date +%Y%m%d)_0200-SVN.$branch.tar.bz2 >/tmp/squirrelmail.tar.bz2 && \
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
    chown www-data:www-data /var/local/squirrelmail/attach && \
    ln -s /data/squirrelmail /var/local/squirrelmail/data && \
    sed "/memory_limit/s/=.*/=$memory_limit/;/post_max_size/s/=.*/=$post_max_size/;/upload_max_filesize/s/=.*/=$upload_max_filesize/;/max_execution_time/s/=.*/=$max_execution_time/;" /usr/local/etc/php/php.ini-production >$PHP_INI_DIR/php.ini && \
    ln -s ../mods-available/remoteip.load /etc/apache2/mods-enabled/remoteip.load && \
    echo RemoteIPHeader X-Forwarded-For >/etc/apache2/mods-enabled/remoteip.conf && \
    echo RemoteIPTrustedProxy 172.17.0.0/16 >>/etc/apache2/mods-enabled/remoteip.conf && \
    # move everything to /var/www/html dir
    mv /var/www/html /var/www/html.bak && \
    mv /squirrelmail /var/www/html && \
    # cleanup and create a link to where everything is
    rm /tmp/squirrelmail.tar.bz2 && \
    rm -rf /squirrelmail* && \
    ln -s /var/www/html /squirrelmail

EXPOSE 80
