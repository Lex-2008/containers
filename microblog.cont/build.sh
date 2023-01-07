rm -rf build
mkdir -p build
rsync -ai --filter=':- .gitignore' --filter=':- .dockerignore' microblog.pub/ build
cd build

# good idea about using tac's: https://unix.stackexchange.com/a/467850
tac ../microblog.pub/Dockerfile  | sed '0,/^FROM/d;$!{/^FROM/d};$s/ as .*//' | tac | tee Dockerfile.build

docker build -t microblog:build -f Dockerfile.build .

mkdir -p rootfs
docker create --name extract microblog:build 
docker cp extract:/opt/venv rootfs
docker rm -f extract

chmod -R 777 venv

# sed '1!{/^FROM/,/^FROM/d};1s/ as .*//;s/^COPY --from.*/COPY rootfs $PYSETUP_PATH/' ../microblog.pub/Dockerfile | tee Dockerfile
sed '1!{/^FROM/,/^FROM/d};1s/ as .*//;s/^COPY/#COPY/;s/^RUN chown.*app/#&/;/^#COPY --from.*/a COPY rootfs/venv $PYSETUP_PATH/' ../microblog.pub/Dockerfile | tee Dockerfile


docker build -t microblog:latest -f Dockerfile .
