#!/bin/bash

pass_to_command=""
declare -a exclude_paths
while getopts ":hx:c:" opt; do
  case $opt in
    x)
	  IFS=':' read -r -a exclude_path_option <<< "$OPTARG"
	  exclude_paths=("${exclude_paths[@]}" "${exclude_path_option[@]}")
      ;;
    h)
      cat <<EOF
Calls a command from the first valid place in the PATH environment variable,
this is no different then just typing the command but using the -x option
you can exclude certain paths from executing the command if it exists there.

Usage: call_from_path [-x $exclude_paths] command $command_options_and_arguments
   -x   List of paths to exclude from calling the
        command from, these should be separted by
        the ':' symbol
   -c   Pass the calling of this command and all of it's arguments to
        another command passed in by this parameter
   -h   displays basic help
EOF
      exit 0
      ;;
    c)
      pass_to_command="${OPTARG} "
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done
shift $(($OPTIND - 1))

#If no command is passed then exit
if [ "$#" -lt 1 ]; then
	echo "No Command Passed" >&2
	exit 1
fi

#Go through all non excluded paths and check if the command exists.
#If it does call it with all of it's arguments and exit
bash_command="$1"
IFS=':' read -r -a paths <<< "$PATH"
for path in "${paths[@]}"; do
  if [[ ! " ${exclude_paths[@]} " =~ " ${path} " ]] && [ -f "${path}/${bash_command}" ]; then
    arguments_and_options=""
    for argument_or_option in "${@:2}"; do
      arguments_and_options=`printf "${arguments_and_options} %q" "$argument_or_option"`
    done
    eval "${pass_to_command}${path}/${bash_command}${arguments_and_options}"
    exit $?
	fi
done

#If no command is found then print error and exit with error
cat >&2 <<EOF
${bash_command}: command not found
paths excluded from execution path:
EOF
for path in "${exclude_paths[@]}"; do
  echo "\"$path\"" >&2
done
exit 1
