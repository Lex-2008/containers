FROM alpine

RUN apk --no-cache add \
    bash curl openssl \
    git bind-tools

WORKDIR /data

CMD [ "./dehydrated", "-c" ]
