#
# See ./CONTRIBUTING.rst
#

OS := $(shell uname)
.PHONY: help
.DEFAULT_GOAL := help

PROJECT := ansible-role-python

PYTHON_VERSION=3.6.4
PYENV_NAME="${PROJECT}"

# Configuration.
SHELL ?=/bin/bash
ROOT_DIR=$(shell pwd)
MESSAGE:=🍺️
MESSAGE_HAPPY:="Done! ${MESSAGE} | Now Happy Coding"
SOURCE_DIR=$(ROOT_DIR)/
REQUIREMENTS_DIR=$(ROOT_DIR)/requirements
PROVISION_DIR:=$(ROOT_DIR)/provision
FILE_README:=$(ROOT_DIR)/README.rst
PATH_DOCKER_COMPOSE:=provision/docker-compose
DOCKER_SERVICE=app

pip_install := pip install -r
docker-compose:=docker-compose -f docker-compose.yml

include provision/make/*.mk

help:
	@echo '${MESSAGE} Makefile for ${PROJECT}'
	@echo ''
	@echo 'Usage:'
	@echo '    environment               create environment with pyenv'
	@echo '    clean                     remove files of build'
	@echo '    setup                     install requirements'
	@echo ''
	@make alias.help
	@make docker.help
	@make test.help

clean:
	@echo "$(TAG)"Cleaning up"$(END)"
ifneq (Darwin,$(OS))
	@sudo rm -rf .tox *.egg *.egg-info dist build .coverage .eggs .mypy_cache
	@sudo rm -rf docs/build
	@sudo find . -name '__pycache__' -delete -print -o -name '*.pyc' -delete -print -o -name '*.pyo' -delete -print -o -name '*~' -delete -print -o -name '*.tmp' -delete -print
else
	@rm -rf .tox *.egg *.egg-info dist build .coverage .eggs .mypy_cache
	@rm -rf docs/build
	@find . -name '__pycache__' -delete -print -o -name '*.pyc' -delete -print -o -name '*.pyo' -delete -print -o -name '*~' -delete -print -o -name '*.tmp' -delete -print
endif
	@echo

setup: clean
	@echo "=====> install setup to ${PYENV_NAME}..."
	$(pip_install) "${REQUIREMENTS_DIR}/setup.txt"
	@if [ -e "${REQUIREMENTS_DIR}/private.txt" ]; then \
			$(pip_install) "${REQUIREMENTS_DIR}/private.txt"; \
	fi
	pre-commit install
	cp -rf .hooks/prepare-commit-msg .git/hooks/
	@if [ ! -e ".env" ]; then \
		cp -rf .env-sample .env;\
	fi
	@echo $(MESSAGE_HAPPY)

environment: clean
	@echo "=====> loading virtualenv ${PYENV_NAME}..."
	@pyenv virtualenv ${PYTHON_VERSION} ${PYENV_NAME} >> /dev/null 2>&1; \
	@pyenv activate ${PYENV_NAME} >> /dev/null 2>&1 || echo $(MESSAGE_HAPPY)
