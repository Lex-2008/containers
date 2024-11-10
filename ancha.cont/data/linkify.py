import os
import re
import sys

base_url=sys.argv[1]
# base_dir=sys.argv[2]
base_dir='.'

text=sys.stdin.read()

text=text.replace('https://www.youtube.com/edit?o=U&video_id=', 'https://www.youtube.com/watch?v=')


def http2link(m):
    url=title=m.group(0)
    rest=''

    # cut trailing dots and commas, if any
    mm=re.search('[,.)]*$', url)
    if mm.group(0):
        url=title=url[:-len(mm.group(0))]
        rest=mm.group(0)

    # fancy formatting for known youtube videos
    for prefix in ['https://www.youtube.com/watch?v=', 'https://www.youtube.com/live/', 'https://youtube.com/live/', 'https://youtu.be/']:
        if url.startswith(prefix):
            id=url[len(prefix):]
            id=id[:11]
            files = os.listdir(base_dir)
            for filename in files:
                mm=re.match('[0-9]{8}-%s-(.*).description$' % id, filename)
                if mm:
                    title=mm.group(1)
                    return '<a href="{}" data-title="{}">{}</a>{}<sup><a href="#s{}">[#]</a></sup>'.format(url,title,url,rest,id)

    return '<a href="{}">{}</a>{}'.format(url,title,rest)

text=re.sub('https?://[^\s<>]*',http2link,text)

def time2link(m):
	hms=m.group(0).split(':')
	if len(hms)==2:
		hms.insert(0,'0')
	hms=list(map(lambda x: int(x), hms))
	sec=hms[0]*60*60 + hms[1]*60 + hms[2]
	url=base_url+str(sec)
	return '<a href="{}">{}</a>'.format(url,m.group(0))

print(re.sub('(\d\d?:)?\d\d?:\d\d',time2link,text))

