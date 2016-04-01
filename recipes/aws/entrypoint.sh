#!/bin/sh
export DEFAULT_COMMAND=${DEFAULT_COMMAND:-"aws"}

case "$1" in
    config|configure)
        aws configure
        ;;
        
    version)
        ${DEFAULT_COMMAND} --version
        ;;
        
    shell)
        bash
        ;;
         
    *)
        ${DEFAULT_COMMAND} $@;;
esac
