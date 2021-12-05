#!/bin/sh

echo "HTTP/1.0 200 OK"
echo

# ### useful env vars ###
# export PATH_INFO='/path'
# export QUERY_STRING='query'

# expected input: $PATH_INFO=/123/p/456
# where 'p' is one of: pmtd

q="$(echo $PATH_INFO | tr 'm/pdt' '- +/*')"
qlen="${#q}"
export BC_LINE_LENGTH="$qlen"
qlen0="$(head -c 16 </dev/zero | tr '\0' '0')"

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

for char_n in `seq "$al"`; do
	# suggest replacing digit with 0 (max=10) only if:
	# it's not 1st digit, or
	# whole number is 1-digit long
	# (it doesn't make sense to change 12 to 02,
	# but it's ok to chane 1 to 0)
	test "$char_n" != 1 -o "$al" = 1 && max=10 || max=9
	sed_expr="$(for n in `seq 1 $max`; do echo "${n}s/./$n/$char_n"; done | sed 's_/10/_/0/_')"
	numbers="$(for _ in `seq 10`; do echo "$a"; done | sed "$sed_expr;/$a/d" | sort )"
	for number in $numbers; do
		prn "$number" "$o" "$b"
	done
done

if ! test "$a" = "0"; then
	test "$al" -gt 1 && prn "${a::-1}" "$o" "$b"
	prn "${a}0" "$o" "$b"
	prn "${a}000000" "$o" "$b"
	test "$qlen" -ge 12 && prn "$a$qlen0" "$o" "$b"
fi

echo "</ul><p>Try other values of 2<sup>nd</sup> operand:</p><ul>"

for char_n in `seq "$bl"`; do
	# suggest replacing digit with 0 (max=10) only if:
	# it's not 1st digit, or
	# whole number is 1-digit long and it's not a division operation
	# (in addition to $a, it doesn't make sense to change 1 to 0
	# if it's a division operation)
	test "$char_n" != 1 -o "$al" = 1 -a "$o" != "d" && max=10 || max=9
	sed_expr="$(for n in `seq 1 $max`; do echo "${n}s/./$n/$char_n"; done | sed 's_/10/_/0/_')"
	numbers="$(for _ in `seq 10`; do echo "$b"; done | sed "$sed_expr;/$b/d" | sort )"
	for number in $numbers; do
		prn "$a" "$o" "$number"
	done
done

if ! test "$b" = "0"; then
	test "$bl" -gt 1 && prn "$a" "$o" "${b::-1}"
	prn "$a" "$o" "${b}0"
	prn "$a" "$o" "${b}000000"
	test "$qlen" -ge 12 && prn "$a" "$o" "$b$qlen0"
fi

echo "</ul>"
echo "</body></html>"
