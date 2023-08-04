docker run -d -p 139:139 -p 445:445 --name smb --hostname $HOSTNAME -e TZ=Asia/Shanghai \
    -v /data/share/data:/share/folder elswork/samba \
    -u "$(id -u):$(id -g):$(id -un):$(id -gn):password" \
    -s "SmbShare:/share/folder:rw:$(id -un)"
