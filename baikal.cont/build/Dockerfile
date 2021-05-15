FROM alpine
# based on original work of
# Dmitry Prazdnichnov <dp@bambucha.org>
# https://github.com/bambocher/docker-baikal/blob/master/Dockerfile
MAINTAINER https://github.com/Lex-2008

ENV VERSION  0.8.0

RUN apk --no-cache add lighttpd php7-cgi php7-ctype php7-dom \
    php7-pdo_sqlite php7-xml php7-openssl php7-json \
    php7-xmlreader php7-xmlwriter php7-session \
    &&  wget https://github.com/sabre-io/Baikal/releases/download/$VERSION/baikal-$VERSION.zip -O /tmp/baikal.zip \
    && unzip /tmp/baikal.zip && rm /tmp/baikal.zip \
    && rm -rf /baikal/Specific /baikal/config \
    && ln -s /data/Specific /data/config /baikal

EXPOSE 8000
USER 1000:1000
CMD ["lighttpd", "-D", "-f", "/data/lighttpd.conf"]
