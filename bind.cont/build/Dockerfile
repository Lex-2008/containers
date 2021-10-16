FROM alpine

RUN apk --no-cache add bind

EXPOSE 53
#USER 1000:1000
CMD ["named", "-c", "/data/named.conf", "-L", "/data/logs/bind.log", "-f", "-u", "named"]
