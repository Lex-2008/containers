FROM alpine

RUN apk --no-cache add busybox-extras sqlite

EXPOSE 8000
USER 1000:1000
CMD ["httpd", "-f", "-p", "8000", "-h", "/data/current/backup3/web"]
