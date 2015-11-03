#!/usr/bin/env docker-machine

function machine_create_default() {
    __attn "Creating machine '${DOCKER_MACHINE_DEFAULT_NAME}'..."
    local machine_state=`docker-machine status ${DOCKER_MACHINE_DEFAULT_NAME} 2>/dev/null`
    if [ -n "${machine_state}" ]; then
        __info "Removing machine..."
        docker-machine rm --force ${DOCKER_MACHINE_DEFAULT_NAME}
    fi
    docker-machine create \
        --driver=virtualbox \
        ${DOCKER_MACHINE_DEFAULT_NAME}
    machine_forward_ports 8080 8080
    machine_forward_ports 49000 49900
    machine_nfs_mount
}

function machine_current_env() {
    __attn "Environment:"
    __value "DOCKER_ENV_ROOT" "${DOCKER_ENV_ROOT}"
    __value "DOCKER_ENV_ROOT_PARENT" "${DOCKER_ENV_ROOT_PARENT}"
    __value "DOCKER_ENV_PROJECTS_PATH" "${DOCKER_ENV_PROJECTS_PATH}"
    __value "DOCKER_VERSION" "${DOCKER_VERSION}"
    __value "BOOT2DOCKER_ISO_VERSION" "${BOOT2DOCKER_ISO_VERSION}"
    __value "DOCKER_COMPOSE_VERSION" "${DOCKER_COMPOSE_VERSION}"
    __value "DOCKER_MACHINE_VERSION" "${DOCKER_MACHINE_VERSION}"
    __value "DOCKER_MACHINE_DEFAULT_NAME" "${DOCKER_MACHINE_DEFAULT_NAME}"
    __msg ""
    if [[ -n "${DOCKER_MACHINE_NAME}" ]]; then 
        __attn "Active Machine:"
        __value "DOCKER_MACHINE_NAME" "${DOCKER_MACHINE_NAME}"
        __msg ""
        __attn "Docker Env:"
        __value "DOCKER_TLS_VERIFY" "${DOCKER_TLS_VERIFY}"
        __value "DOCKER_HOST" "${DOCKER_HOST}" 
        __value "DOCKER_CERT_PATH" "${DOCKER_CERT_PATH}"
    else
        __err "A machine has not been created or made active yet..."
    fi
        __msg ""
    __attn "Versions:"
    __value "docker" "`docker version --format='{{ .Client.Version  }}'`"
    __value "docker-compose" "`docker-compose version --short`"
    __value "docker-machine" "`docker-machine --version | grep -oh '\d*\.\d*\.\d*.*'`"
}

function machine_forward_ports() {
    if [ -n "${1}" ] && [ -n "${2}" ]; then
        __attn "Forwarding ports $1 thru $2"
        for port in $(seq ${1} ${2}); do
            __msg "Attempting to remove port forwarding for port ${port}..."
            VBoxManage controlvm ${DOCKER_MACHINE_NAME} \
                natpf1 delete "tcp-port${port}" &>/dev/null
            VBoxManage controlvm ${DOCKER_MACHINE_NAME} \
                natpf1 delete "udp-port${port}" &>/dev/null
            __msg "Attempting to forward port ${port}..."
            VBoxManage controlvm ${DOCKER_MACHINE_NAME} \
                natpf1 "tcp-port${port},tcp,,${port},,${port}" &>/dev/null
            VBoxManage controlvm ${DOCKER_MACHINE_NAME} \
                natpf1 "udp-port${port},udp,,${port},,${port}" &>/dev/null
        done
        __info "Port forwarding completed. Restarting machine..."
        docker-machine restart ${DOCKER_MACHINE_NAME}
        machine_ip
    else
        __err "You must provide and starting and ending port number!"
    fi
}

function machine_ip() {
    __value "IP" `docker-machine ip ${DOCKER_MACHINE_NAME}`
}

function machine_ssh() {
    if [[ -n "$@" ]]; then
        docker-machine ssh ${DOCKER_MACHINE_NAME} "${@};printf ''"
    else
        docker-machine ssh ${DOCKER_MACHINE_NAME}
    fi
}

function machine_nfs_mount() {
    __attn "Adding a mount point using NFS..."
    
    local mount_point=${1:-${DOCKER_ENV_ROOT}}
    local machine=${2:-${DOCKER_MACHINE_NAME}}
    local machine_ip=`docker-machine ip ${DOCKER_MACHINE_NAME} 2>/dev/null`
    local host_only_adapter=`VBoxManage showvminfo ${machine} | \
        sed -En "s/^.+Host-only.+'(.*)'.*$/\1/p"`
    local host_only_ip=`VBoxManage list hostonlyifs | \
        egrep -A9 "Name:            ${host_only_adapter}\$" | \
        awk '/IPAddress:/ {print $2}'`
    local map_user=`whoami`
    local map_group=$(sudo -u ${map_user} id -n -g)
    local opts="rw,async,noatime,rsize=32768,wsize=32768,proto=tcp,nfsvers=3"

    __value "mount point" ${mount_point}
    __value "machine" ${machine}
    __value "machine ip" ${machine_ip}
    __value "host only ip" ${host_only_ip}
    __value "map user" ${map_user}
    __value "map group" ${map_group}

    sudo chmod u+rw /etc/exports
    sudo chmod u+rw /etc/nfs.conf

    # Backup /etc/nfs.conf file
    cp -n /etc/nfs.conf /etc/nfs.conf.bak
    __info "Backed up /etc/nfs.conf to /etc/nfs.conf.bak"

    NFS_OK=$(grep "nfs.server.mount.require_resv_port = 0" /etc/nfs.conf > /dev/null)
    if [ "$?" != "0" ]
    then
      echo "nfs.server.mount.require_resv_port = 0" >> /etc/nfs.conf
    fi

    # Backup exports file
    $(cp -n /etc/exports /etc/exports.bak) && \
      __info "Backed up /etc/exports to /etc/exports.bak"

    __info "Current Exports:"
    CURRENT_EXPORTS=`cat /etc/exports | grep -v "${mount_point}.*${machine_ip}"`
    if [ -n "${CURRENT_EXPORTS}" ]; then
      # display and delete previously generated lines 
      echo "${CURRENT_EXPORTS}" | sed '/^\s*$/d' | sudo tee /etc/exports
    else
      __err "No existing exports defined in /etc/exports..."
    fi

    MAPPING="\"${mount_point}\" ${machine_ip} -alldirs -mapall=${map_user}:${map_group}"
    __info "Adding to /etc/exports..."
    echo ${MAPPING} | sudo tee -a /etc/exports

    sudo nfsd restart
    __info "Waiting several seconds for nfsd to restart..."
    sleep 5 

    __attn "Setting up NFS on docker host..."
    __info "Unmounting ${mount_point}..."
    machine_ssh "sudo umount -f ${mount_point} &>/dev/null"
    machine_ssh "sudo mkdir -p ${mount_point}"

    __info "Restarting nfs-client"
    machine_ssh "sudo /usr/local/etc/init.d/nfs-client restart 2> /dev/null"
    __info "Waiting 10s for nfsd and nfs-client to restart."
    sleep 10

    __info "Mounting ${mount_point}"
    machine_ssh "sudo mount ${host_only_ip}:${mount_point} ${mount_point} -o ${opts}"

    __info "Files:"
    machine_ssh "ls -al ${mount_point}"

    __info "nfsstat -m"
    machine_ssh "/usr/local/sbin/nfsstat -m"
}
