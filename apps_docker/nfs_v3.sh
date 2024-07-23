. ./_pre.sh

NFS_EXPORT=/data/share

n=nfs_v3 ; docker stop $n 2>/dev/null; docker rm $n 2>/dev/null

run "\
docker run -d --privileged --restart=unless-stopped \
    -v $NFS_EXPORT:/nfsshare \
    -p 111:111 -p 111:111/udp \
    -p 2049:2049 -p 2049:2049/udp \
    -p 32765-32768:32765-32768 -p 32765-32768:32765-32768/udp \
    --name $n tangjiujun/nfs-server:v1.0
"

. ./_post.sh $n