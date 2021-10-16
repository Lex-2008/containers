FROM alpine

RUN apk --no-cache add lighttpd bind-tools

EXPOSE 8004
USER 1000:1000
CMD ["lighttpd", "-D", "-f", "/data/lighttpd.conf"]
