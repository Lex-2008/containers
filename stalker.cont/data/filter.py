#!/usr/bin/python3
#
# Filter URLs passed on stdin line-by-line:
# * URL must start with 'base' (passed as 1st arg)
# * URL must not start with one of URL prefixes in 'nogo.txt' file
# * URL must not end with one of forbidden file extensions

import sys

base=sys.argv[1]

with open("nogo.txt", "r") as f:
    nogos=[l.strip() for l in f.readlines()]

for url in sys.stdin.readlines():
    # print('looking at ['+url+']')
    good=True
    if not url.startswith(base):
        # print('no base: '+url)
        continue
    for nogo in nogos:
        if url.startswith(nogo):
            # print('nogo: '+url)
            good=False
            break
    if not good:
        continue
    url=url.strip()
    for ext in ['.png', '.gif', '.jpg', '.jpeg', '.pdf', '.webp', '/atom.xml']:
        if url.endswith(ext):
            # print('ext: '+url)
            good=False
            break
    if not good:
        continue
    print(url)
