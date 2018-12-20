parted -s /dev/$1 mklabel gpt
parted -s /dev/$1 unit mib mkpart primary 0% 100%

mkfs.ext4 /dev/${1}1

mkdir /mnt/$2
echo >> /etc/fstab
echo /dev/${1}1               /mnt/$2       ext4    defaults,noatime 0 0 >> /etc/fstab
mount /mnt/$2
