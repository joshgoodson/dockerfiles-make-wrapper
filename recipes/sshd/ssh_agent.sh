#!/bin/sh -e

finish() {
    rm -f /tmp/agent.sock
}
trap finish EXIT

ln -sf $SSH_AUTH_SOCK /tmp/agent.sock

tail -f /dev/null
