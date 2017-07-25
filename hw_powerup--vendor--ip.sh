case $1 in 
	dell )
		ssh root@$2 'racadm serveraction  powerup'
		;;
esac
