curl -k -s https://www.cloudflare.com/ips-v4 | sed 's/.*/allow &;/;$a deny all;' >cloudflare.conf
