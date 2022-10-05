import re
import sys
import datetime

min_age=int(sys.argv[1])
prefix=sys.argv[2]

now=datetime.datetime.now()

for line in sys.stdin.readlines():
	m = re.match('^(\d+)-(.{11})', line)
	if not m:
		continue
	thisdate = datetime.datetime.strptime(m.group(1), '%Y%m%d')
	if (now-thisdate).days > min_age:
		print('{} {}'.format(prefix, m.group(2)))
