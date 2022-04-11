#!/bin/bash

system_command=`basename "$0"`

if [ $# -ge 1 ]; then
    custom_command="$1"
    command_name="$system_command-$custom_command"
    if command -v "$command_name" > /dev/null; then
        "$command_name" "${@:2}"
        exit $?
    fi
fi

call_from_path -x `dirname "${BASH_SOURCE[0]}"` "$system_command" "$@"
exit $?
