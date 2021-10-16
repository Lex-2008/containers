FROM debian:bullseye-slim
MAINTAINER https://github.com/Lex-2008

RUN apt-get update && \
    apt-get install -y \
    opendkim opendkim-tools inetutils-syslogd \
    --no-install-recommends && \
    apt-get clean && \
    adduser --system --no-create-home --group syslog && \
    echo '*.* /data/logs/mail.log' >/etc/syslog.conf


EXPOSE 2301
#CMD syslogd && exec opendkim -x /data/conf/opendkim.conf
CMD chown root:syslog /dev && chmod g+w /dev && \
    runuser -u syslog syslogd && \
    chown root:root /dev && chmod g-w /dev && \
    exec opendkim -x /data/conf/opendkim.conf
