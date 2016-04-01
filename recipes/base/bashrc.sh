#!/bin/bash

umask 022
test -r /root/.dircolors && eval "$(dircolors -b /root/.dircolors)" || eval "$(dircolors -b)"
if [ -x /usr/bin/dircolors ]; then
    alias ls='ls --color=auto'
    alias ll='ls --color=auto -GlahF'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias top='top; clear'
alias psa='ps -aut'
