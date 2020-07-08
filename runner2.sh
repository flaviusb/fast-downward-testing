#!/bin/bash

downward=0
if [ -f ~/code/Fast-Downward-c9844230bcf2/builds/release/bin/downward ]; then
  downward=`ls ~/code/Fast-Downward-c9844230bcf2/builds/release/bin/downward`
fi
sas=0
if [ -f ~/code/Fast-Downward-c9844230bcf2/output.sas ]; then
  sas=`ls ~/code/Fast-Downward-c9844230bcf2/output.sas`
fi
gdbx=0
if [ -f gdb.x ]; then
  gdbx=`ls gdb.x`
fi
gdbcommand="gdb"

usage() { cat <<HELP
runner2.sh: Memory size measuring harness for fast downward.
Options:
  --downward     QUOTED PATH
                 Full path to downward executable
  --sas          QUOTED PATH
                 Full path to the sas file to search
  --gdbx         PATH
                 Path to the gdb harness
  --gdb-command  PATH or name
                 Command to run gdb

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
      --gdbx)
        gdbx="$value"
        shift
        shift
        ;;
      --gdb-command)
        gdbcommand="$value"
        shift
        shift
        ;;
      *)
        echo "I don't understand: $opt"
        exit 1
        ;;
    esac
done

if [ $sas = 0 ]; then
  echo "No sas file found."
  exit 3
fi

if [ $downward = 0 ]; then
  echo "No downward executable found."
  exit 4
fi

if [ $gdbx = 0 ]; then
  echo "No gdb harness file found."
  exit 3
fi

cat "$sas" | $gdbcommand -se="$downward" -x "$gdbx"
#gdb -se="$downward" -x gdb.x
