case $1 in 
	dell )
		echo actions: powerdown powerup powerstatus graceshutdown hardreset powercycle 
		echo Doc: http://www.dell.com/support/manuals/us/en/04/integrated-dell-remote-access-cntrllr-8-with-lifecycle-controller-v2.00.00.00/racadm_idrac_pub-v1/serveraction?guid=guid-69ea52c5-153d-4369-b7c4-6694a3b9e0d4&lang=en-us
		ssh root@$2 "racadm serveraction  $3"
		;;
esac
