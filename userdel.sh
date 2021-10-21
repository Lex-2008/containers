user="${1:?first arg must be username}"
sed -i "/^$user@/d" postfix.cont/data/conf/users.txt
sed -i "/^$user:/d" dovecot.cont/data/conf/passwd.txt
sed -i "/^$user:/d" nginx.cont/data/passwd/mail.txt
