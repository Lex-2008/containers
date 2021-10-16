FROM debian:bullseye-slim
MAINTAINER https://github.com/Lex-2008

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    opendkim-tools busybox && \
    apt-get clean

EXPOSE 8000
USER 1000:1000
CMD ["busybox", "httpd", "-f", "-p", "8000", "-h", "/data/html"]
