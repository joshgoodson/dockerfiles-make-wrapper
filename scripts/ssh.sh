#!/bin/bash

function ssh_forward_agent() {
    rm -rf ${DIR}/.data/ssh/*
    compose_up sshd 
    local ip=`docker inspect --format '{{(index (index .NetworkSettings.Ports "22/tcp") 0).HostIp }}' sshd`
    __info "sshd container ip: ${ip}"
    ssh-keyscan -p 2022 ${ip} > ${DIR}/.data/ssh/known_hosts 2>/dev/null
    ssh -f -A \
        -i recipes/base/insecure_key \
        -o "StrictHostKeyChecking no" \
        -o "UserKnownHostsFile=${DIR}/.data/ssh/known_hosts" \
        -p 2022 \
        root@docker.local /root/ssh_agent.sh
    __info "Agent forwarding successfully started."
}
