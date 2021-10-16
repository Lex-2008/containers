#!/bin/busybox sh

echo "HTTP/1.0 200 OK"
echo "Content-Type: text/plain"
echo

busybox httpd -d "`tail --bytes=+3`" | opendkim-testmsg 2>&1 && echo OK
