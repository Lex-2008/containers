FROM alpine

RUN apk --no-cache add bind

EXPOSE 5353
USER 100:101
CMD ["named", "-4", "-c", "/data/named.conf", "-f", "-L", "/data/logs/bind.log", "-p", "5353"]
