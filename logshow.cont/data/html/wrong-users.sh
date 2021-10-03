echo "HTTP/1.0 200 OK"
echo

awk '/User unknown/{gsub("shpakovsky.ru", "", $24); gsub("shpakovsky", "$(hostname)"); gsub("<", "\\&lt;"); gsub(">", "\\&gt;"); gsub("^unknown", "", $10); print "<tr><td>" $1 " " $2 "</td><td>" $10 "</td><td>" $23 "</td><td>" $24 "</td><td>" $26 "</td></tr>"}' /postfix-logs/mail.log | tac
