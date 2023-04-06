. ../lib/init.sh

run 'docker network ls'

files=( $(ls -t *.yml) )
[ ${#files[@]} -eq 0 ] && exit_err "no ./_.yml file found!"

for i in "${!files[@]}"; do
  printf '[%s] %s\n' "$i" "${files[i]}"
done

read -p "which to run: " i
[[ $i =~ [0-9]+ ]] || exit_err non-num

f=${files[i]}

run "head $f"
h=$(cat $f | grep routers | grep Host | grep -oP '(?<=`).*(?=`)')

n=$(echo $f | cut -d. -f1)

run "docker-compose -f $f -p $n up --remove-orphans -d"
run "docker-compose ls"

run "docker ps | grep $n"

[ -n "$h" ] && echo_tip "curl -H Host:$h http://127.0.0.1 --head"

run "docker logs -f $n"
