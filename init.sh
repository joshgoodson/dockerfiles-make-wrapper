#!/usr/bin/env bash

SHELL=`ps -p $$ | grep "tty" | awk '{ print $4 }'`
if [[ "${SHELL}" == *bash ]]; then
    export DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ) 
else
    export DIR=$( cd "$( dirname "${(%):-%N}" )" && pwd )
fi

export DOCKER_ENV_ROOT="${DIR}"
export DOCKER_ENV_ROOT_PARENT="$(dirname ${DOCKER_ENV_ROOT})"
export DOCKER_ENV_PROJECTS_PATH="${DOCKER_ENV_ROOT}/projects"
export DOCKER_ENV_ACTIVE_PROJECT=""
export DOCKER_ENV_ACTIVE_PROJECT_PATH=""
export DOCKER_VERSION=1.9.1
export BOOT2DOCKER_ISO_VERSION=1.9.1
export DOCKER_COMPOSE_VERSION=1.5.1
export DOCKER_MACHINE_VERSION=0.5.1
export DOCKER_MACHINE_DEFAULT_NAME=boot2docker
export INSTALL_LOG="${DOCKER_ENV_ROOT}/.install_log"

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

touch "${DOCKER_ENV_ROOT}/.env"

# docker, compose, machine scripts
source ${DOCKER_ENV_ROOT}/scripts/docker.sh
source ${DOCKER_ENV_ROOT}/scripts/compose.sh
source ${DOCKER_ENV_ROOT}/scripts/machine.sh
source ${DOCKER_ENV_ROOT}/scripts/setup_osx.sh

function make_eval_env() {
    if [ -e "${DOCKER_ENV_ROOT}/.env" ]; then
        local env=`cat "${DOCKER_ENV_ROOT}/.env"` 
        eval "${env}"
    fi
}

function make_update_env() {
    __attn "Updating .env file..."
    eval `docker-machine env ${DOCKER_MACHINE_DEFAULT_NAME}` 
    cat <<ENVFILE > "${DOCKER_ENV_ROOT}/.env"
export DOCKER_TLS_VERIFY="${DOCKER_TLS_VERIFY}"
export DOCKER_HOST="${DOCKER_HOST}"
export DOCKER_CERT_PATH="${DOCKER_CERT_PATH}"
export DOCKER_MACHINE_NAME="${DOCKER_MACHINE_NAME}"
export DOCKER_ENV_ACTIVE_PROJECT="${DOCKER_ENV_ACTIVE_PROJECT}"
export DOCKER_ENV_ACTIVE_PROJECT_PATH="${DOCKER_ENV_ACTIVE_PROJECT_PATH}"
ENVFILE
    make_eval_env
    __info ".env file updated..."
}

function make_action() {
    local machine_state=`docker-machine status ${DOCKER_MACHINE_DEFAULT_NAME} 2>/dev/null`
    if [ -z "${machine_state}" ]; then
        machine_create_default
        make_update_env
    else
        case "$1" in
            help)
                clear
                __attn "github.com/brianclaridge/dockerfiles"
                __head "> make setup osx -- installs brew, brew-cask, docker, docker-compose and docker-machine"
                __head "> make create default -- creates a docker host using boot2docker/virtualbox"
                __head "> make ip -- displays the current machine ip"
                __head "> make ssh -- ssh into the current machine"
                __head "> make forward [port] [port] -- forwards a range of ports"
                __head "> make env -- displays current environment values"
                __head "> make nfs -- adds nfs mount point"
                __head "> make ps -- displays active containers"
                __head "> make ls -- displays all tagged images"
                __head "> make clean -- removes containers and dangling images"
                __head "> make nuke -- forcefully removes ALL containers and images"
                __head "> make project [name] -- sets the active compose project"
                __head "> make build [service] -- builds a service"
                __head "> make run [service] [command] [args] -- run a single command"
                __head "> make up [service] -- start and attach to a service"
                ;;

            # machine, setup stuff
            setup)
                case "${2}" in
                    osx|default)
                        setup_osx
                        ;;
                esac
                ;;

            info|env)
                machine_current_env
                ;;

            create)
                case "${2}" in
                    default)
                        machine_create_default
                        ;;
                esac
                make_update_env
                ;;

            ip)
                machine_ip
                ;;

            ssh)
                machine_ssh
                ;;

            forward)
                machine_forward_ports ${2} ${3}
                ;;

            nfs)
                machine_nfs_mount
                ;;

            fix)
                machine_fix
                make_update_env
                ;;

            # docker stuff
            docker)
                docker_wrapper "${@:2}"
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

            nuke)
                docker_kill
                docker_rm
                docker_remove_all_images
                ;;

            # compose stuff
            project)
                compose_set_project "${2}"
                make_update_env
                ;;

            compose)
                compose_wrapper "${@:2}"
                ;;

            build)
                compose_build "${@:2}"
                ;;

            run)
                compose_run "${@:2}"
                ;;

            up)
                compose_up "${@:2}"
                ;;

            *)
                clear
        esac
    fi
}

make_eval_env
make_action "${@}"

# EOF
