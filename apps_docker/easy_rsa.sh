. ../linux/init.sh

n=easy-rsa_`ts`
d=/var/lib/docker/volumes/$n/_data/pki/
t=/tmp/easy-rsa

while read s
do
    [ -n "$s" ] && echo "docker run -it --rm -v $n:/mnt/ chrisgavin/easy-rsa $s"
done <<< '
init-pki
gen-dh
build-ca nopass
build-server-full server nopass
build-client-full client nopass
'

if [ ! -d $t ]; then
    mkdir -p easy-rsa
    cp -p $d/ca.crt $d/dh.pem $d/issued/* $d/private/* $t/
else
    ls -l $t
fi