lspci--egrep() {
    lspci -nn | egrep -i $1 | egrep -o '[0-9a-z]{4}:[0-9a-z]{4}' | xargs -n1 -I% sh -c "lspci -nnk -d %;printf '\n';"
}

check_video_amd(){
    dpkg -l amdgpu-pro
}

check_video_glxgears() {
    GALLIUM_HUD=help glxgears
}

check_cpu_core_mapping(){
    # https://www.ibm.com/support/knowledgecenter/en/SSQPD3_2.6.0/com.ibm.wllm.doc/mappingcpustocore.html
    # same physical/core ID  =》 simultaneous multi threads (SMTs) / HT
    cat /proc/cpuinfo  | grep -P 'processor|physical id|core id|^$'

    # pip install walnut    # pretty print
    # for c in sorted([ ( int(c['processor']), int(c['physical id']), int(c['core id']) ) for c in cpu.dict().values()]): print c
}