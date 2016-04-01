APP_DIRS=asset services

#!/usr/bin/make -f
SHELL = /bin/bash

# name of the command to run
CMD = $(word 1, $(MAKECMDGOALS))

# any optional arguments to a pass on to command
ARGS = $(wordlist 2,100,$(MAKECMDGOALS))

# turn args into 'do nothing' goals
$(eval $(ARGS):;@:)

.PHONY: all $(APP_DIRS) $(ARGS)
all: 
	@make help

%:
	@chmod +x scripts/*.sh
	@chmod +x init.sh
	@exec /bin/bash -c 'source ./init.sh ${CMD} ${ARGS}'
