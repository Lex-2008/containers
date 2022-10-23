Fetch descriptions and subtitles of a Youtube channel
=====================================================

Using [yt-dlp][]

[yt-dlp]: https://github.com/yt-dlp/yt-dlp/

Features:

* All descriptions of all videos on one page.

* Time marks in description (MM:SS) are converted to hyperlinks to relevant times.

* auto-generated subtitles are converted to plaintext file with "links"
  to relevant time of the video

Drawbacks:

* Comments are not fetched - if channel author didn't put time marks into description
  (but keeps them in a comments, even in a pinned one) - they are not fetched.

* Descriptions edited more than a week after original upload are not re-fetched anymore
  To fix, manually remove relevant `*.description` file and run `dl.sh` -
  video will be refetched anew.

* If a video title was changed less than a week after a video was uploaded -
  it causes duplicate entries. To fix, manually remove obsolete `*.description`
  and similarly-named subtitle files.

To see results, navigate to <http://ancha-times.chat.ru/>

Requirements
------------

Currently designed to run on Debian 11 "bullseye" with Python3 (hard dependency),
zip (weak dependency, only to compress subtitles txt file), and
curl (weak dependency, only to upload artifacts to third-party servers) installed.

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

