#!/bin/sh

# this file must contain usernames and passwords for services used further,
# in format like this:
# SERVICE_USERPASS=username:password
. ./secrets.txt

curl --silent --user "$CHATRU_USERPASS" --upload-file index.koi8r.html ftp://ancha-times.chat.ru/index.html
