FROM debian:bullseye-slim
MAINTAINER https://github.com/Lex-2008

RUN apt-get update && \
    apt-get install -y \
    opendkim opendkim-tools inetutils-syslogd \
    --no-install-recommends && \
    apt-get clean && \
    echo '*.* /data/logs/mail.log' >/etc/syslog.conf


EXPOSE 2301
CMD syslogd && exec opendkim -x /data/conf/opendkim.conf
