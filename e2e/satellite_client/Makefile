include ../common.mk

NODEJS_DOCKER=satellite_client
DOCKER_COMPOSE_FILE=../services_templates.yaml
DOCKER_WORKDIR=${E2E_ROOT}/satellite_client

ifneq ($(GITHUB_ACTION),)
CACHING_SETTINGS := --cache-to type=gha,mode=max,scope=$GITHUB_REF_NAME-dart-client --cache-from type=gha,scope=$GITHUB_REF_NAME-dart-client
# else
# CACHING_SETTINGS := --cache-to type=local,dest=docker_cache,mode=max --cache-from type=local,src=docker_cache
endif
# By default we would like to build in docker, as we intend
# to run tests with Satellite in it
build:
	docker buildx build --no-cache --load ${CACHING_SETTINGS} -f ./Dockerfile -t satellite_dart_client:local ${PROJECT_ROOT}

local-build:
	dart compile exe bin/satellite_dart_client.dart -o satellite_dart_client

