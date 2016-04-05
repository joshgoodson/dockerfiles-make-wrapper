#!/usr/bin/env bash

SHELL=`ps -p $$ | grep "tty" | awk '{ print $4 }'`

if [[ "${SHELL}" == *bash ]]; then
    export DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ) 
else
    export DIR=$( cd "$( dirname "${(%):-%N}" )" && pwd )
fi

export DOCKER_VM_IP=`ping -q -c 1 docker.local | sed -En "s/^.*\((.+)\).*$/\1/p"`

# bash colors
bgblack="$(tput setab 0)"
black="$(tput setaf 0)"
red="$(tput setaf 1; tput bold)"
green="$(tput setaf 2; tput bold)"
yellow="$(tput setaf 3; tput bold)"
blue="$(tput setaf 4; tput bold)"
magenta="$(tput setaf 5; tput bold)"
cyan="$(tput setaf 6; tput bold)"
gray="$(tput setaf 7)"
reset="$(tput sgr0)"

__head() { printf "${green}$*${reset}\n"; } 
__info() { printf "${yellow}$*${reset}\n"; } 
__attn() { printf "${magenta}$*${reset}\n"; } 
__err() { printf "${red}$*${reset}\n";} 
__msg() { printf "$*\n"; }
__value() { printf "${green}${1}:${reset} ${yellow}${2}${reset}\n"; }

if [[ "${SHELL}" == *bash ]]; then
    export -f __head
    export -f __info
    export -f __attn
    export -f __err
    export -f __msg
    export -f __value
fi

source scripts/docker.sh
source scripts/compose.sh

function update_current_service() {
    echo "${1}" > .data/current_service
}

function make_target_handler() {
    if [ "$#" -gt 0 ]; then
        if [ -n "${2}" ]; then
            update_current_service ${2}
        fi
        service=${2:-`cat .data/current_service`}
        
        case "$1" in
            help)
                make_menu_help
                ;;
            
            run)
                compose_run ${service} ${@:3}
                ;;
            
            up)
                compose_up ${service}
                ;;
            
            bash)
                docker exec -it ${service} bash
                ;;
                
            logs)
                compose_logs ${service}
                ;;
            
            open)
                port_binding=`docker inspect -f "{{ .HostConfig.PortBindings }}" ${service} | sed -En "s/^map\[(.+)\:.+$/\1/p"`
                port_mapping=`docker port ${service} ${port_binding}`
                browser="Google Chrome"
                open -a "${browser}" http://${port_mapping}
                ;;
            
            build)
                compose_build ${service}
                ;;
            
            ps)
                docker_ps
                ;;

            ls|images)
                docker_ls
                ;;

            clean)
                docker_kill
                docker_rm
                docker_remove_untagged_images
                ;;

            nuke|purge)
                docker_kill
                docker_rm
                docker_remove_untagged_images
                docker_remove_all_images
                ;;
            
            ip)
                __info ${DOCKER_VM_IP}
                ;;

            *)
                __err "'${1}' target not supported..."
        esac
    else
        make_menu_help
    fi
}

function make_menu_help() {
    tput clear
    local cols=`expr $(tput cols) - 10`
    printf "${green}"'=%.0s'"${reset}" $(seq 1 $cols)
    printf "\n"

    __info "TARGETS:"
    __msg "> make help -- displays this help"
    __msg "> make build [service] -- docker-compose build [service]"
    __msg "> make run [service] -- docker-compose run --service-ports --rm [service] [args]"
    __msg "> make up [service] -- docker-compose up -d [service]"
    __msg "> make logs [service] -- docker-compose logs [service]"
    __msg "> make open [service] -- attempts to open Google Chrome using first port mapping"
    __msg "> make bash [container] -- docker exec -it [container] bash"
    __msg "> make ps -- lists all running containers"
    __msg "> make images -- lists all tagged images"
    __msg "> make clean -- kills all containers, removes dangling images"
    __msg "> make purge -- kills all containers, removes all images" 
    __msg "> make ip -- ip address of xhyve vm"

    printf "${green}"'=%.0s'"${reset}" $(seq 1 $cols)
    printf "\n"
}

make_target_handler "${@}"

# EOF
