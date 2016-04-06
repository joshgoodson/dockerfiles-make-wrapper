#!/bin/bash

case "$1" in
    daemon)
        /usr/sbin/sshd -D
        ;;
         
    *)
        /root/ssh_agent.sh
esac
