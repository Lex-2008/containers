FROM alpine

RUN apk add --no-cache postfix && \
    newaliases

EXPOSE 25

CMD [ "postfix", "-c", "/data/conf", "start-fg" ]
