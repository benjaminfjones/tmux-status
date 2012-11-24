#!/usr/bin/env bash

set -e

HERE=$(cd `dirname $0;`; pwd)

SCRIPT_DIR=$HERE/scripts
SEPARATOR=" "
DEFAULT_ITEM_ATTR=""
PREFIX=""
SUFFIX=""

function script_path {
    local name=$1
    echo "$SCRIPT_DIR/$name.sh"
}

function script_exists {
    local name=$1
    local pth=$(script_path $name)
    [ -f $pth ]
}

function build_status {
    local config=$1
    local status=""

    # For each status script specified in the configuration, run it
    # and build up a status line.  A config is just a file with one
    # script name per line (no suffix).
    . $config

    for name in $SCRIPTS
    do
        if [ -z $name ]
        then
            continue
        fi

        if ! script_exists $name
        then
            error "No such script: $name"
            exit 1
        fi

        local pth=$(script_path $name)

        if [ ! -x $pth ]
        then
            error "Script $pth not executable"
            exit 1
        fi

        local output=$($pth)

        if [ -z "$output" ]
        then
            continue
        fi

        if [ ! -z "$status" ]
        then
            status="${status}${SEPARATOR}"
        else
            status="${DEFAULT_ITEM_ATTR}${PREFIX}"
        fi

        status="${status}${DEFAULT_ITEM_ATTR}${output}"
    done

    if [ ! -z "$status" ]
    then
        status="${status}${DEFAULT_ITEM_ATTR}${SUFFIX}"
    fi

    echo $status
}

function error {
    echo "$*" >&2
}

function usage {
    error "Usage: $0 <config>"
}

if [ -z "$1" ]
then
    usage
    exit 1
fi

if [ ! -f "$1" ]
then
    error "No such file: $1"
    usage
    exit 1
fi

build_status $1
