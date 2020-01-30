[ -f init.sh ] && source init.sh || source /dev/stdin <<< "$(curl -sSL https://raw.githubusercontent.com/fzinfz/scripts/master/linux/init.sh)"

print_usage(){ 

    echo_tip "Usage exampels: "
    cat_script README.md | perl -ne 'print if /^# install.sh/ ... /^#/' | head -n-1 | tail -n+2

    echo_tip "values for -f=..."
    cat_script install.sh | grep -oP '^install_\w[^(]+(?=\(\)\{)' | sed s/install_// | grep -v _
    echo_tip "vscodei=code-insiders"
    echo

    echo_tip "values for -p=..."
    cat_script install.sh | perl -ne 'print if /^packages_list()/ ... /^EOF/' | head -n-1 | tail -n+3

}

packages_list(){
cat <<EOF

    base_sys:     software-properties-common openssh-server tmux
    base_hw:      numactl pciutils
    base_web:     aria2 curl wget
    base_text:    vim git gettext jq    
    base_fs:      unzip locate ncdu lsof 
    base_fs_net:  cifs-utils nfs-common
    base_net:     nmon net-tools bridge-utils bmon iputils-ping nload iftop dnsutils tcpdump mtr nmap nethogs traceroute
    base_perf:    iperf3 sysstat htop iotop
    bench:        sysbench fio
    VT:           libvirt-daemon virt-manager qemu-kvm qemu-utils
    docker:       docker.io
    X:            inxi mc
    firefox:      firefox-esr firefox-esr-l10n-zh-cn firefox-esr-l10n-zh-tw
    chrome:       chromium chromium-l10n    
    hack:         trickle wondershaper 

EOF
}


install_vscode_update(){
    if [ ! -f /etc/apt/trusted.gpg.d/microsoft.gpg ]; then
        curl -sSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.gpg
    fi
    
    fgrep packages.microsoft.com/repos/vscode /etc/apt/sources.list.d/vscode.list 1>/dev/null
    [ $? -ne 0 ] && echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list

    repo_update
}
install_vscode(){  install_vscode_update; run $pkg_mgmt install -y code ; }
install_vscodei(){ install_vscode_update; run $pkg_mgmt install -y code-insiders ; }


detect_cmd(){
    if command -v apt >/dev/null 2>/dev/null; then
        pkg_mgmt=apt
    elif command -v yum >/dev/null 2>/dev/null; then
        pkg_mgmt=yum
    else
        echo "only apt & yum supported"
        exit
    fi
    run which $pkg_mgmt
}

repo_update(){
    if [ "$pkg_mgmt" = "apt" ];then
        run apt update
        run apt install -y apt-utils
    elif [ "$pkg_mgmt" = "yum" ];then
        run yum update -y
        run yum install -y epel-release
    fi
}

package_install(){
    run $pkg_mgmt install -y ${packages_array[@]}
    
    if [ $? -ne 0 ]; then
        for pkg in ${packages_array[@]}; do
            run $pkg_mgmt install -y $pkg
        done
    fi
}

echo_script_header
detect_cmd

unset packages functions to_install to_update_repo

for i in "$@"; do
    case $i in
        -h|--help)
            print_usage && exit
        ;;
        -u|--update)
            to_update_repo="Y"
        ;;
        -i|--install)
            to_install="Y"
        ;;        
        -p=*|--packages=*)
            packages="${i#*=}"
            regex_packages="\s*${packages//,/|}"
            echo_debug "regex_packages=$regex_packages"
        ;; 
        -f=*|--functions=*)
            functions="${i#*=}"
            echo_debug "functions=$functions"
        ;;           
        *)
            echo_error "Unknown Parameter: $i"
        ;;
    esac
done


[ "$to_update_repo" = "Y" ] && repo_update

# Exit if `-p` and `-f` both empty

if [ -z "$packages" ] && [ -z "$functions" ]; then
    print_usage && exit
fi

# For `-f`

echo_debug "Processing package installation..."
for func in $functions; do
    run "install_$func"
done

[ -z "$packages" ] && exit

# For `-p`

packages_array_pre=( $(packages_list | grep -P $regex_packages) )
packages_array=( $(printf -- '%s\n' "${packages_array_pre[@]}" | fgrep -v : | sort) )

[ "${#packages_array[@]}" -eq 0 ] && echo_error "No packages detected" && exit

echo_debug "Processing package installation..."
[ "$to_install" = "Y" ] && package_install || echo_tip "add -i to install: ${packages_array[@]}"

# Ending

echo_script_header
