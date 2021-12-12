#!/bin/sh

echo "HTTP/1.0 200 OK"
echo "Content-Type: text/html"
echo

# ### useful env vars ###
# export PATH_INFO='/path'
# export QUERY_STRING='query'

# expected input: $PATH_INFO=/123/p/456
# where 'p' is one of: pmtd

q="$(echo $PATH_INFO | tr 'm/pdt' '- +/*')"
qlen="${#q}"
qlen0="$(head -c "$qlen" </dev/zero | tr '\0' '0')"

a="$(echo "$PATH_INFO" | cut -d/ -f2)"
o="$(echo "$PATH_INFO" | cut -d/ -f3)" #operand letter, one of pmtd
b="$(echo "$PATH_INFO" | cut -d/ -f4)"

al="${#a}"
bl="${#b}"

ans="$(echo "scale=$qlen-4;$q" | bc | tr -d '\n\\' | sed 's/^\./0./;/\./s/\.\?0*$//')" # -4 here so scale=number of only digits in q
test "$o$b" = "d0" && ans="&infin;"

o2op() {
	echo "$1" | tr 'mpdt' '-+/*'
}

prn() {
	echo "<li><a href='$1$2$3.html'>$1$(o2op "$2")$3</a></li>"
}

ans="$a$(o2op "$o")$b = $ans"

echo "<html><head><title>$ans</title></head>"
echo "<body><h1>$ans</h1>"

echo "<p>Try other operations:</p><ul>"

test "$o" != "p" && prn "$a" "p" "$b"
test "$o" != "m" && prn "$a" "m" "$b"
test "$o" != "t" && prn "$a" "t" "$b"
test "$o" != "d" -a "$b" != "0" && prn "$a" "d" "$b"

echo "</ul><p>Try other values of 1<sup>st</sup> operand:</p><ul>"

# check if we need to delete 1st line which suggests to replace 1st digit with 0.
# It makes sense only if whole number is 1-digit long
# (it doesn't make sense to change 56 to 06, but it's ok to chane 5 to 0).
# Worth noting that 1st line always suggests to replace 1st digit with 0.
# Exception would be a number which starts with 0, but we don't have them here :)
if test "$al" = 1; then
	del10='';
else
	del10='1d;'
fi

nums "$a" | sed "${del10}s_.*_<li><a href='&$o$b.html'>&$(o2op "$o")$b</a></li>_"

if ! test "$a" = "0"; then
	test "$al" -gt 1 && prn "${a::-1}" "$o" "$b"
	prn "${a}0" "$o" "$b"
	prn "${a}000000" "$o" "$b"
	test "$qlen" -ge 12 && prn "$a$qlen0" "$o" "$b"
fi

echo "</ul><p>Try other values of 2<sup>nd</sup> operand:</p><ul>"

# check if we need to delete 1st line which suggests to replace 1st digit with 0.
# It makes sense only if whole number is 1-digit long,
# AND operation is not division
# (NOTE that it's a difference with similar fragment above)
if test "$bl" = 1 -a "$o" != "d"; then
	del10='';
else
	del10='1d;'
fi

nums "$b" | sed "${del10}s_.*_<li><a href='$a$o&.html'>$a$(o2op "$o")&</a></li>_"

if ! test "$b" = "0"; then
	test "$bl" -gt 1 && prn "$a" "$o" "${b::-1}"
	prn "$a" "$o" "${b}0"
	prn "$a" "$o" "${b}000000"
	test "$qlen" -ge 12 && prn "$a" "$o" "$b$qlen0"
fi

echo "</ul></body></html>"
