# prepend output of logshow/spam-emails.sh script to a static file
cd /containers/nginx.cont/data/public/alexey.shpakovsky.ru/en/
wget -q http://alexey.shpakovsky.ru/logshow/spam-emails.sh -O spam-emails-3.htm.new
cat spam-emails-3.htm >>spam-emails-3.htm.new
chown --reference=spam-emails-3.htm spam-emails-3.htm.new
mv spam-emails-3.htm.new spam-emails-3.htm
