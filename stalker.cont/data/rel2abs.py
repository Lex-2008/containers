#!/usr/bin/python3
#
# Convert (possibly relative) URLs passed on stdin line-by-line 
# to absolute URLs
# Note that python 'urljoin' has explicit list of supported protocols,
# so here we just replace protocol with one which this script hopefully won't ever see

from urllib.parse import urljoin
import sys

base=sys.argv[1].replace('gemini://','prospero://')
for url in sys.stdin.readlines():
    print(urljoin(base,url.strip()).replace('prospero://','gemini://'))
