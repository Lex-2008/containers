FROM debian:bullseye-slim
MAINTAINER https://github.com/Lex-2008

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 python3-pip && \
    apt-get clean && \
    pip install python-smail

EXPOSE 1025
USER 1000:1000
CMD "/data/serv.py"
