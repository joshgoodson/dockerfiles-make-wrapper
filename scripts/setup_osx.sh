#!/bin/bash

function setup_osx() {
    setup_brew
    setup_brew_cask
    setup_virtualbox
    setup_docker
    setup_docker_compose
    setup_docker_machine
}

function setup_brew() {
    local brew_loc=`which brew`
    if [ -z "${brew_loc}" ]; then
        __info "installing brew..."
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi
    __info "updating brew..."
    which brew
    sudo chown -R `whoami` /usr/local/.git
    sudo chgrp -R admin /usr/local
    sudo chmod -R g+w /usr/local
    sudo chgrp -R admin /Library/Caches/Homebrew &>/dev/null
    sudo chmod -R g+w /Library/Caches/Homebrew &>/dev/null
    brew update >> ${INSTALL_LOG} 2>&1
    __info "brew setup completed..."
}

function setup_brew_cask() {
    __attn "installing brew-cask..."
    if setup_is_app_installed brew-cask; then
        brew upgrade brew-cask >> ${INSTALL_LOG} 2>&1
        brew cleanup >> ${INSTALL_LOG} 2>&1
        brew cask cleanup >> ${INSTALL_LOG} 2>&1
    else
        brew tap caskroom/cask >> ${INSTALL_LOG} 2>&1
        brew_install brew-cask 
    fi
    __info "brew-cask setup completed..."
}

function setup_is_app_installed() {
    if [ -n "`brew list $1 2>/dev/null | grep $1`" ]; then
        return 0
    fi
    return 1
}

function setup_is_brew_cask_installed() {
    if [ -n "`brew cask list $1 2>/dev/null | grep $1`" ]; then
        return 0
    fi
    return 1
}

function setup_brew_install() {
    __attn "brew installing $1..."
    brew install $1 --force >> ${INSTALL_LOG} 2>&1
    brew link --overwrite $1 >> ${INSTALL_LOG} 2>&1
    if [ -n "$2" ]; then
        brew switch $1 $2 >> ${INSTALL_LOG} 2>&1
    fi
}

function setup_cask_install() {
    __attn "brew cask installing $1..."
    brew cask install $1 --force >> ${INSTALL_LOG} 2>&1
}

function setup_brew_uninstall() {
    __info "brew uninstalling $1..."
    brew unlink $1 >> ${INSTALL_LOG} 2>&1
    brew uninstall --force $1 >> ${INSTALL_LOG} 2>&1
}

function setup_cask_uninstall() {
    __info "brew cask uninstalling $1..."
    brew cask uninstall --force $1 >> ${INSTALL_LOG} 2>&1
}

function setup_docker() {
    __attn "installing docker ${DOCKER_VERSION}..."
    if setup_is_app_installed docker; then
        setup_brew_uninstall docker
    fi
    setup_brew_install docker ${DOCKER_VERSION}
    __info "docker setup completed..."
}

function setup_docker_compose() {
    __attn "installing docker-compose ${DOCKER_COMPOSE_VERSION}..."
    if [ -f "/usr/local/bin/docker-compose" ]; then
        rm -rf /usr/local/bin/docker-compose
        rm -rf /usr/local/bin/fig
    fi
    curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` \
        > /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    ln -sf /usr/local/bin/docker-compose /usr/local/bin/fig
    __info "docker-compose setup completed..."
}

function setup_docker_machine() {
    __attn "installing docker-machine ${DOCKER_MACHINE_VERSION}..."
    curl -L https://github.com/docker/machine/releases/download/v${DOCKER_MACHINE_VERSION}/docker-machine_darwin-amd64.zip \
        > /tmp/machine.zip && \
        unzip /tmp/machine.zip -d /tmp &>/dev/null && \
        rm /tmp/machine.zip && \
        mv /tmp/docker-machine* /usr/local/bin
    chmod +x /usr/local/bin/docker-machine
    ln -sf /usr/local/bin/docker-machine /usr/local/bin/dm
    __info "docker-machine setup completed..."
}

function setup_docker_machine() {
    __attn "installing docker-machine ${DOCKER_MACHINE_VERSION}..."
    curl -L https://github.com/docker/machine/releases/download/v${DOCKER_MACHINE_VERSION}/docker-machine_darwin-amd64.zip \
        > /tmp/machine.zip && \
        unzip /tmp/machine.zip -d /tmp &>/dev/null && \
        rm /tmp/machine.zip && \
        mv /tmp/docker-machine* /usr/local/bin
    chmod +x /usr/local/bin/docker-machine
    ln -sf /usr/local/bin/docker-machine /usr/local/bin/dm
    __info "docker-machine setup completed..."
}

function setup_virtualbox() {
    __attn "installing VirtualBox..."
    if [ ! -z `which vboxmanage` ]; then
        local vms=`setup_virtualbox_list` 
        if [[ -n "$vms" ]]; then
            while read -r line; do
                __err "Powering off VM: ${line}"
                vboxmanage controlvm $line acpipowerbutton >> ${INSTALL_LOG} 2>&1
            done <<< "$vms"
        fi
        local pid=`pgrep -o -x VirtualBox`
        if [ -n "${pid}" ]; then
            kill ${pid} >> ${INSTALL_LOG} 2>&1
        fi
    fi
    setup_cask_install virtualbox
}

function setup_virtualbox_list() {
    local vms=`vboxmanage list runningvms | sed -En "s/.*\{(.*)\}.*/\1/p"` 
    echo "${vms}"
}
