#!/usr/bin/env docker-compose

function compose_set_project() {
    export DOCKER_ENV_ACTIVE_PROJECT="${1}"
    export DOCKER_ENV_ACTIVE_PROJECT_PATH="${DOCKER_ENV_PROJECTS_PATH}/${DOCKER_ENV_ACTIVE_PROJECT}"
    __attn "'${DOCKER_ENV_ACTIVE_PROJECT}' is now the active compose project..."
}

function compose_wrapper() {
    ( cd ${DOCKER_ENV_ACTIVE_PROJECT_PATH}; \
        docker-compose ${@} )
}

function compose_build() {
    local service=${1}
    __attn "Building the '${DOCKER_ENV_ACTIVE_PROJECT}, ${service}' service..."
    ( cd ${DOCKER_ENV_ACTIVE_PROJECT_PATH}; \
        docker-compose build ${service} )
}

function compose_run() { 
    local service=${1}
    __attn "Running command using the '${DOCKER_ENV_ACTIVE_PROJECT}, ${service}' service..."
    ( cd ${DOCKER_ENV_ACTIVE_PROJECT_PATH}; \
        docker-compose run --rm --service-ports ${service} ${@:2} )
}

function compose_up() { 
    __attn "Bring up the '${DOCKER_ENV_ACTIVE_PROJECT}, ${service}' service..."
    local service=${1}
    ( cd ${DOCKER_ENV_ACTIVE_PROJECT_PATH}; \
        docker-compose up ${service} ${@:2} )
}
