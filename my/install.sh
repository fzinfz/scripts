cd ../linux/ && ./install.sh -p=base -i && cd -

lscpu | grep "Hypervisor vendor" |  grep -i kvm
[ $? -ne 0 ] `# if not VM` && {
    cd ../linux/ && ./install.sh -p=hw_basic -i && cd -
}
