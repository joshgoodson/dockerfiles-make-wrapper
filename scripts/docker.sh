#!/usr/bin/env docker

function docker_image_id() {
    local imgid=`docker inspect --format "{{ .Id }}" ${1} 2>/dev/null`
    echo -n "${imgid}"
}

function docker_container_id() {
    local cid=`docker ps --no-trunc --quiet --filter="name=${1}" 2>/dev/null`
    echo -n "${cid}"
}

function docker_any_container() {
    local cid=`docker ps -a --no-trunc --quiet --filter="name=${1}" 2>/dev/null`
    echo -n "${cid}"
}

function docker_container_ip() {
    local cip=""
    if [ -n "$1" ]; then
        cip=`docker inspect --format="{{ .NetworkSettings.IPAddress }}" ${1}`
    fi 
    echo -n "${cip}"
}

function docker_container_status() {
    local state=""
    if [ -n "$1" ]; then
        local running=`docker inspect --type=container --format="{{ .State.Running }}" ${1}`
        local paused=`docker inspect --type=container --format="{{ .State.Paused }}" ${1}`
        local restarting=`docker inspect --type=container --format="{{ .State.Restarting }}" ${1}`
        if [[ "${paused}" == "true" ]]; then
            state="${cyan}paused${reset}"
        elif [[ "${restarting}" == "true" ]]; then
            state="${cyan}restarting${reset}"
        elif [[ "${running}" == "true" ]]; then
            state="${green}running${reset}"
        else
            state="${red}not running${reset}"
        fi
    fi 
    echo -n "${state}"
}

function docker_ps() {
    local containers=`docker ps --all=false -q 2> /dev/null`
    local line="%-35s %-35s %-16s %-16s %s\n"
    printf "${magenta}${line}${reset}" "IMAGE" "NAME" "ID" "IP"
    if [[ -n "$containers" ]]; then
        while read -r id; do
            image=`docker inspect --format="{{ .Config.Image }}" ${id}`
            if [ ${#image} -gt 34 ]; then
                image="${image:0:10}..."
            fi
            name=`docker inspect --format="{{ .Name }}" ${id} | cut -c2-`
            if [ ${#name} -gt 34 ]; then
                name="${name:0:30}..."
            fi
            ip=`docker inspect --format="{{ .NetworkSettings.IPAddress }}" ${id}`
            printf "${cyan}${line}${reset}" \
                "${image}" "${name}" "${id}" "${ip}"
        done <<< "$containers"
    else
        __err "No active containers..." 
    fi
}

function docker_ls() {
    __attn "IMAGES:"
    local images=`docker images --all=true -q 2> /dev/null`
    if [[ -n "${images}" ]]; then 
        docker images 
    else
        __err "No images to list..." 
    fi
}  

function docker_kill() {
    __head "Killing containers..."
    local containers=`docker ps --quiet`
    if [[ -n "$containers" ]]; then
        while read -r id; do
            __attn "Killing ${id}..."
            docker kill ${id} &>/dev/null
        done <<< "$containers"
    else
        __err "No containers to kill..."
    fi
    echo -n "" 
}

function docker_rm() { 
    __head "Removing containers..."
    local containers=`docker ps -aq`
    if [[ -n "$containers" ]]; then
        while read -r id; do
            image=`docker inspect --format "{{ .Config.Image }}" ${id}`
            running=`docker inspect --format "{{ .State.Running }}" ${id}`
            if [ "$running" = false ]; then 
                __attn "Removing container: ${id}, from image: '${image}'..."
                docker rm -f ${id} &>/dev/null
            else 
                __err "Can't remove running container: ${id}"
            fi
        done <<< "$containers"
    else
        __err "No containers to remove..."
    fi
    echo -n "" 
}

function docker_remove_untagged_images() {
    __head "Removing untagged images..."
    local images=`docker images --quiet --filter "dangling=true"`
    if [[ -n "${images}" ]]; then
        while read -r id; do
            __attn "Removing ${id}..."
            docker rmi --force=true ${id} &>/dev/null
        done <<< "${images}"
    else
        __err "No un-tagged, dangling images to remove..."
    fi
    echo -n "" 
}

function docker_remove_all_images() {
    __head "Removing all images..."
    local images=`docker images --all=true -q 2> /dev/null`
    if [[ -n "${images}" ]]; then
        while read -r id; do
            __attn "Removing ${id}..."
            docker rmi --force=true ${id} &>/dev/null
        done <<< "${images}"
    else
        __err "No images to remove..."
    fi
    echo -n "" 
}
