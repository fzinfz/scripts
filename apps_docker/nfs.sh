. ./_pre.sh

NFS_EXPORT=/data

n=nfs ; docker stop $n 2>/dev/null; docker rm $n 2>/dev/null

run "\
docker run --name nfs \
    -d --restart unless-stopped \
    --net host --privileged \
    -v $NFS_EXPORT:/nfsshare \
    -e SHARED_DIRECTORY=/nfsshare \
    itsthenetwork/nfs-server-alpine:latest
"

echo_tip "on client, you may run: "

for ip in `hostgit dname --all-ip-addresses`; do
cat << EOF
    nmap -sV -p2049 $ip
    mkdir -p /data_nfs && mount.nfs4 $ip:/ /data_nfs
EOF
echo
done

cat << EOF
    cat /proc/mounts | grep nfs  >> /etc/fstab
EOF

. ./_post.sh $n