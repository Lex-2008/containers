echo "HTTP/1.0 200 OK"
echo

awk '/Relay access denied/{gsub("shpakovsky", "$(hostname)"); gsub("<", "\\&lt;"); gsub(">", "\\&gt;"); gsub("^unknown", "", $10); print "<tr><td>" $1 " " $2 "</td><td>" $10 "</td><td>" $17 "</td><td>" $18 "</td><td>" $20 "</td></tr>"}' /postfix-logs/mail.log | uniq | tac
