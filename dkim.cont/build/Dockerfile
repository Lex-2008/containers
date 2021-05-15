FROM alpine
MAINTAINER https://github.com/Lex-2008

RUN apk add --no-cache opendkim

EXPOSE 2301
#USER 1000:1000
CMD [ "opendkim", "-x", "/data/conf/opendkim.conf" ]
