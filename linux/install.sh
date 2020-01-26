    [ -f init.sh ] && source init.sh || source /dev/stdin <<< "$(curl -sSL https://raw.githubusercontent.com/fzinfz/scripts/master/init.sh)"

print_usage(){
cat <<'EOF'

    Usage examples: ( can be used together with other parameters )
        -u            # update repo
        -p=base       # dry run for packages will be installed, will grep `$regex_packages`
        -p=base|X -i  # install packages
        -f=vscode     # run install_*() functions in script, don't need -i
        # Others: vscodei(code-insiders) 

EOF
}

packages_list(){
cat <<EOF

    base_sys:     software-properties-common tmux htop
    base_hw:      numactl pciutils
    base_web:     aria2 curl wget
    base_text:    vim git gettext jq    
    base_fs:      unzip locate ncdu lsof 
    base_fs_net:  cifs-utils nfs-common
    base_net:     nmon net-tools bridge-utils bmon iputils-ping nload iftop dnsutils tcpdump mtr nmap nethogs traceroute
    base_bench:   iperf3 sysstat
    bench:        sysbench fio
    X:            inxi mc
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

	# $pkg_mgmt --fix-broken install -y
}
install_vscode(){  install_vscode_update; run $pkg_mgmt install code ; }
install_vscodei(){ install_vscode_update; run $pkg_mgmt install code-insiders ; }


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
    run $pkg_mgmt install ${packages_array[@]}
    
    if [ $? -ne 0 ]; then
        for pkg in ${packages_array[@]}; do
            run $pkg_mgmt install $pkg
        done
    fi
}

echo_script_header
detect_cmd

unset packages functions to_install to_update_repo

for i in "$@"; do
    case $i in
        -h|--help)
            print_usage  
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


[ to_update_repo = "Y" ] && repo_update


if [ -z "$packages" ] && [ -z "$functions" ]; then
    print_usage && exit
fi


echo_debug "Processing package installation..."
for func in $functions; do
    run "install_$func"
done

[ -z "$packages" ] && exit

packages_array_pre=( $(packages_list | grep -P $regex_packages) )
packages_array=( $(printf -- '%s\n' "${packages_array_pre[@]}" | fgrep -v : | sort) )

[ "${#packages_array[@]}" -eq 0 ] && echo_error "No packages detected" && exit

echo_debug "Processing package installation..."
[ to_install = "Y" ] && package_install || echo "add -i to install: ${packages_array[@]}"

echo_script_header
