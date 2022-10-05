import re
import sys

base_url=sys.argv[1]

text=sys.stdin.read()

def time2link(m):
	hms=m.group(0).split(':')
	if len(hms)==2:
		hms.insert(0,'0')
	hms=list(map(lambda x: int(x), hms))
	sec=hms[0]*60*60 + hms[1]*60 + hms[2]
	url=base_url+str(sec)
	return '<a href="{}">{}</a>'.format(url,m.group(0))

print(re.sub('(\d\d?:)?\d\d?:\d\d',time2link,text))

