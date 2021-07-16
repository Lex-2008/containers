echo "HTTP/1.0 200 OK"
echo

grep 'NOQUEUE.*blocked using rbl.rbldns.ru' /postfix-logs/mail.log | sed -r '/from=<>/d;s/^(...) (..) .* RCPT from ([^:]*): .* from=<([^>]*)>( .* helo=<([^>]*)>)*.*/\1@\2@\4<\/td><td>from \3<\/td><td>helo \6/;s/>from unknown\[/>from [/;s/] helo $//;s/shpakovsky/$(hostname)/' | LC_ALL=C sort -u -t '@' -k 1,1Mr -k 2,2r -k 4 -k 3 | sed -n 's/@/ /; s/@/%/; H; g;/^\(... ..\)\n\1/!{s/.*\n\(.*\)%.*/<tr><td>\1<\/td><\/tr>/;p}; g;s/.*%\(.*\)/<tr><td>\1<\/td><\/tr>/;p; g;s/.*\n\(.*\)%.*/\1/;h'
