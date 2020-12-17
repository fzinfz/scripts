. ../linux/init.sh

az_login(){ 
    az login --use-device-code
}

az_docker_run(){
    docker run -it \
    -v ${HOME}/.ssh:/root/.ssh \
    mcr.microsoft.com/azure-cli
}

az_lb_inboundNatRules_create(){ 
    az network lb inbound-nat-rule create \
    -g linux --lb-name LB1 -n $1 \
    --protocol Tcp --frontend-port $1 --backend-port $1
}