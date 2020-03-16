#!/bin/bash

downward=`ls ~/code/Fast-Downward-c9844230bcf2/builds/release/bin/downward`
sas=`ls ~/code/Fast-Downward-c9844230bcf2/output.sas`

usage() { cat <<HELP
runner2.sh: Memory size measuring harness for fast downward.
Options:
  --downward  QUOTED PATH
              Full path to downward executable
  --sas       QUOTED PATH
              Full path to the sas file to search

Any argument not given will use a default value.

HELP
exit 0;
}

while [[ $# > 0 ]]; do
    if [ $# = 1 ]; then
      opt="$1"
      case "${opt}" in
        -h)
          usage
          ;;
        --help)
          usage
          ;;
        *)
          echo "I don't understand: $opt"
          exit 1
          ;;
      esac
    fi
    opt="$1"
    value="$2"
    case "${opt}" in
      --downward)
        downward="$value"
        shift
        shift
        ;;
      --sas)
        sas="$value"
        shift
        shift
        ;;
      *)
        echo "I don't understand: $opt"
        exit 1
        ;;
    esac
done



cat "$sas" | gdb -se="$downward" -x gdb.x
#gdb -se="$downward" -x gdb.x
