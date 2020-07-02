#!/bin/bash

# So, we need a filename and a name and wallclock time and resources count for the slurm job
# And we also need to either pass through the arguments for gdb.x.sh and/or runner2.sh or we need to get the locations of the generated scripts
# Then we build the things that need building - and get those paths that way
# And generate the slurm script with the paths and fielname and name and wallclock time and etc
# And then we optionally run it if the run option is selected

# # Options:
# ## Mandatory
#    either "--name x" or "--filename x"
#    * name defaults to `basename -s "$filename"`
#    * filename defaults to ./"$name".sl
#    "--wallclock time"
#    "--memory x"
#    either "--path-to-gdbx x" or "--gdbx-... "
#    either "--path-to-runner2sh x" or "--runner2sh-... "
# ## Optional
#    "--run-immediately"
#    "--help"

usage() { cat <<HELP
slurm-job-generator.sh: Generate a slurm job, and optionally the dependencies
Options:
## Mandatory
   either "--name x" or "--filename x"
   * name defaults to \`basename -s "\$filename"\`
   * filename defaults to ./"\$name".sl
   "--wallclock time"
   "--memory x"
   either "--path-to-gdbx x" or "--gdbx-... "
   either "--path-to-runner2sh x" or "--runner2sh-... "
## Optional
   "--run-immediately"
   "--help"

HELP
exit 0;
}

runimmediately=0
filename=""


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
        --run-immediately)
          runimmediately=1
          ;;
        *)
          echo "I don't understand: $opt"
          exit 1
          ;;
      esac
    else
      opt="$1"
      value="$2"
      case "${opt}" in
        --run-immediately)
          runimmediately=1
          shift
          ;;
        -h)
          usage
          ;;
        --help)
          usage
          ;;
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
    fi
done

