source ../linux/init.sh

setup_grafana(){

    n=grafana ; docker stop $n 2>/dev/null; docker rm $n 2>/dev/null

    run "docker run --name $n -d --restart unless-stopped --net host \
        grafana/grafana"
        
    sleep 2
    lsof -i 2>/dev/null | grep LISTEN | grep ^grafana  
    
    echo_tip "add data source & explore"
    echo_tip "grafana-cli admin reset-admin-password newpass"
    
}

setup_loki(){

    n=grafana_loki ; docker stop $n 2>/dev/null; docker rm $n 2>/dev/null

    run "docker run --name $n -d --restart unless-stopped --net host \
        -v grafana_loki:/loki -v $PWD/conf.d_grafana/loki.yaml:/etc/loki/config.yaml \
        grafana/loki"

    sleep 2
    ls /var/lib/docker/volumes/loki -ld
    lsof -i 2>/dev/null | grep LISTEN | grep ^loki
    
}

setup_promtail(){

    n=grafana_promtail ; docker stop $n 2>/dev/null; docker rm $n 2>/dev/null

    run "docker run --name $n -d --restart unless-stopped --net host \
        -v /var/log:/var/log -v $PWD/conf.d_grafana/promtail.yml:/etc/promtail/config.yml \
        grafana/promtail"

    sleep 2
    run "lsof -i 2>/dev/null | grep LISTEN | grep ^promtail"
    run "docker logs grafana_promtail 2>&1 | tail"

}

read -p 'setup_grafana? (y/n)' a 
[ "$a" = "y" ] && setup_grafana

read -p 'setup_loki? (y/n)' a 
[ "$a" = "y" ] && setup_loki

read -p 'setup_promtail? (y/n)' a 
[ "$a" = "y" ] && setup_promtail

run "docker ps | grep grafana"
