FROM debian:bullseye-slim
MAINTAINER https://github.com/Lex-2008

RUN apt-get update && \
    apt-get install -y \
    curl python3 zip && \
    apt-get clean && \
    mkdir /.cache && \
    chown 1000:1000 /.cache

USER 1000:1000
WORKDIR /data
CMD ["./dl.sh"]
