FROM alpine

RUN apk --no-cache add lighttpd

copy nums.c /
RUN apk --no-cache add gcc musl-dev && \
    gcc /nums.c -o /bin/nums && \
    apk del gcc musl-dev

EXPOSE 8000
USER 1000:1000
CMD ["lighttpd", "-D", "-f", "/data/lighttpd.conf"]
