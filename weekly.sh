cd /containers

# logrotate
ls *.cont/logrotate.sh | xargs -l sh

/containers/dehydrated.cont/run.sh

# clean up
docker ps -qf status=exited | xargs --no-run-if-empty docker rm -f
docker images -qf dangling=true | xargs --no-run-if-empty docker rmi
