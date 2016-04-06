#!/usr/bin/env docker

function docker_ps() {
    local containers=`docker ps --all=false -q 2> /dev/null`
    local line="%-35s %-35s %-16s %-16s %s\n"
    printf "${magenta}${line}${reset}" "IMAGE" "NAME" "ID" "IP"
    if [[ -n "$containers" ]]; then
        while read -r id; do
            image=`docker inspect --format="{{ .Config.Image }}" ${id}`
            network=`docker inspect --format="{{ .HostConfig.NetworkMode }}" ${id}`
            if [ ${#image} -gt 34 ]; then
                image="${image:0:10}..."
            fi
            name=`docker inspect --format="{{ .Name }}" ${id} | cut -c2-`
            if [ ${#name} -gt 34 ]; then
                name="${name:0:30}..."
            fi
            ip=`docker inspect --format="{{ .NetworkSettings.Networks.${network}.IPAddress }}" ${id}`
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
            docker stop ${id} &>/dev/null
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
                __attn "Removing container: ${id}, using image: '${image}'..."
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

function docker_remove_volumes() { 
    __head "Removing volumes..."
    local volumes=`docker volume ls -q`
    if [[ -n "$volumes" ]]; then
        while read -r id; do
            docker volume rm ${id}
        done <<< "$volumes"
    else
        __err "No volumes to remove..."
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
