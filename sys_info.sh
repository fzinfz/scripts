nl="printf \n"

echo LONG_BIG: $(getconf LONG_BIT)
$nl

cat << EOL
Endianness
	https://www.cs.umd.edu/class/sum2003/cmsc311/Notes/Data/endian.html
		In big endian, you store the most significant byte(MSB) in the smallest address.
		In little endian, you store the least significant byte(LSB) in the smallest address.
EOL
lscpu | egrep 'Byte Order'
$nl

file /bin/ps
$nl

inxi -Fxz
