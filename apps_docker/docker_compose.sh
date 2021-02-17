. ../lib/init.sh

run 'docker network ls'

files=( $(ls -t *.yml) )
for i in "${!files[@]}"; do
  printf '[%s] %s\n' "$i" "${files[i]}"
done

read -p "which to run: " i
[[ $i =~ [0-9]+ ]] || exit_err non-num

f=${files[i]}

run "cat $f"; echo
h=$(cat $f | grep routers | grep Host | grep -oP '(?<=`).*(?=`)')

run "docker-compose -f $f up -d --force-recreate"

n=$(echo $f | cut -d. -f1)
run "docker ps | grep $n"

[ -n "$h" ] && echo_tip "curl -H Host:$h http://127.0.0.1 --head"