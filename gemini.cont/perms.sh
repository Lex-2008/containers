cd "${0%/*}"
cd data
mkdir -p donations hosts logs titan votes
chown 1000:1000 donations hosts logs votes
