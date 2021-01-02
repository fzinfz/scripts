dd_bandwidth--M() {
    dd if=/dev/zero of=/tmp/testfile bs=$1M count=1 oflag=direct
}

dd_iops_512--count() {
    dd if=/dev/zero of=/tmp/testfile bs=512 count=$1 oflag=direct
}

bench_dd-iops() {
    dd if=/dev/zero of=/tmp/test_iops bs=512 count=10000 oflag=direct
}

bench_dd-bandwidth() {
    dd if=/dev/zero of=/tmp/test_bw bs=200M count=1 oflag=direct
}

bench_sysbench_cpu() {
    sysbench --test=cpu run
}