Fetch descriptions and subtitles of a Youtube channel
=====================================================

Using [yt-dlp][]

[yt-dlp]: https://github.com/yt-dlp/yt-dlp/

Features:

* All descriptions of all videos on one page.

* Time marks in description (MM:SS) are converted to hyperlinks to relevant times.

* auto-generated subtitles are converted to plaintext file with "links"
  to relevant time of the video

As of writing, you can see results [here][].

[here]: http://alexey.shpakovsky.ru/unlisted/times.html

Requirements
------------

Currently designed to run on Debian 11 "bullseye" with Python3 (hard dependency)
and zip (weak dependency, only to compress subtitles txt file) installed.

Usage with Docker
-----------------

1. Build container using Dockerfile in build subdir, like this:

		docker build -t ancha:latest build

2. Run it like this:

		docker run --rm -v $PWD/data:/data -v $PWD/out:/out ancha

	replacing `$PWD/out` with a directory where you want to see output files

Usage without Docker
--------------------

1. Edit `data/dl.sh` file to your liking
  (you probably want to change `OUT` directory
  and maybe name of `TIMES` file).

2. Run `./dl.sh` file in that directory.

