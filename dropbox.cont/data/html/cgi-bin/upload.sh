#!/bin/sh
# based on https://github.com/mhfan/busybox/blob/master/networking/httpd_post_upload.txt

# POST upload format:
# -----------------------------29995809218093749221856446032^M
# Content-Disposition: form-data; name="file1"; filename="..."^M
# Content-Type: application/octet-stream^M
# ^M    <--------- headers end with empty line
# file contents
# file contents
# file contents
# ^M    <--------- extra empty line
# -----------------------------29995809218093749221856446032--^M

filename="`date +"%F-%T"`-$$-$RANDOM"
file="/data/files/$filename.bin"
meta="/data/files/$filename.txt"

err() {
echo "HTTP/1.0 200 OK
Content-Type: text/html

<style>body{margin: auto; width: 100ex}</style>
<h1>Error</h1>
<p>Error while saving file $filename:</p>
<p>$1</p>
<p>Please press Refresh or Reload (F5) to retry</p>"
exit 1
}

CR=`printf '\r'`

IFS="$CR"
read -r delim_line
IFS=""

while read -r line; do
    test x"$line" = x"" && break
    test x"$line" = x"$CR" && break
    echo "$line" >>"$meta"
done

cat >"$file"

# We need to delete the tail of "\r\ndelim_line--\r\n"
tail_len=$((${#delim_line} + 6))

# Get and check file size
filesize=`stat -c"%s" "$file"`
test "$filesize" -lt "$tail_len" && err "size too small: $filesize"

# Check that tail is correct
dd if="$file" skip=$((filesize - tail_len)) bs=1 count=1000 >"$file.tail" 2>/dev/null
printf "\r\n%s--\r\n" "$delim_line" >"$file.tail.expected"
diff -q "$file.tail" "$file.tail.expected" >/dev/null || err "wrong tail"
rm "$file.tail"
rm "$file.tail.expected"

# Truncate the file
dd of="$file" seek=$((filesize - tail_len)) bs=1 count=0 >/dev/null 2>/dev/null

# Redirect to "success" page
echo "HTTP/1.0 303 See Other
Location: /?$((filesize - tail_len))=$filename
"
