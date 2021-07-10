echo "HTTP/1.0 200 OK"
echo

echo '<tr><th>Datetime (UTC)</th><th>proto</th><th>[username]</th><th>[password]</th><th>source IP</th></tr>'
zcat /nginx-logs/auth.log.gz | tail -n10000 | tac | cut -d' ' -f1,3,6,7,9 | sed 's_^_<tr><td>_;s_ _</td><td>_g;s_$_</td></tr>_;s_:_ _'

