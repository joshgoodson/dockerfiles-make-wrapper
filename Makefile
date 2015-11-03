#!/usr/bin/make -f
SHELL = /bin/bash

# name of the command to run
CMD = $(word 1, $(MAKECMDGOALS))

# any optional arguments to a pass on to command
ARGS = $(filter-out $(CMD), $(MAKECMDGOALS))

# turn args into 'do nothing' goals
$(eval $(ARGS):;@:)

.PHONY: all scripts projects
all:
	@make nil

%:
	@chmod +x scripts/*
	@exec /bin/bash -c 'source ./init.sh ${CMD} ${ARGS}'
