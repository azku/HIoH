PROJECT = ws
PROJECT_DESCRIPTION = New project
PROJECT_VERSION = 0.1.1
LOCAL_DEPS=sasl
DEPS = cowboy emqttc erlydtl
dep_cowboy_commit = master
dep_emqttc = git https://github.com/emqtt/emqttc


CONFIG ?= config/sys.config

EXTRA_CONFIG ?= config/extra.config
all::
       @if ! [ -a ${EXTRA_CONFIG} ]; then echo "[]." > ${EXTRA_CONFIG}; fi

include erlang.mk
