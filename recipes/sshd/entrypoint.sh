#!/bin/bash

finish() {
 rm -f /tmp/auth.socket
}
trap finish EXIT

case "$1" in
    daemon)
        /usr/sbin/sshd -D
        ;;
         
    *)
        /root/ssh_agent.sh
esac
