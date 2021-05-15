for f in *.cont/build; do docker build -t "${f%.cont/build}:latest" $f; done
