#!/usr/bin/env docker

function compose_build() {
    docker-compose --file ${DIR}/docker-compose.yml build $1   
}

function compose_up() {
    docker-compose --file ${DIR}/docker-compose.yml up -d $1     
}

function compose_run() {
    docker-compose --file ${DIR}/docker-compose.yml run $1 ${@:2}    
}

function compose_logs() {
    docker-compose --file ${DIR}/docker-compose.yml logs $1     
}
