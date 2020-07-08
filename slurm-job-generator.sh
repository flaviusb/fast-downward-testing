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
#    "--runner2sh-sas"
#    "--runner2sh-downward"

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
    "--runner2sh-sas"
    "--runner2sh-downward"

HELP
exit 0;
}

runimmediately=0
name=0
filename=0
wallclock=""
memory=""
hasgdbx=0
pathtogdbx=""
hasrunner2sh=0
path2runner2sh=""
runner2shdownward=0
runner2shsas=0

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
        --name)
          name="$value"
          if [ $filename = 0 ]; then
            filename="./$name.sl"
          fi
          shift
          shift
          ;;
        --filename)
          filename="$value"
          if [ $name = 0 ]; then
            name=`basename -s "$filename"`
          fi
          shift
          shift
          ;;
        --wallclock)
          wallclock="$value"
          shift
          shift
          ;;
        --memory)
          memory="$value"
          shift
          shift
          ;;
        --path-to-gdbx)
          hasgdbx=1
          pathtogdbx="$value"
          shift
          shift
          ;;
        --path-to-runner2sh)
          hasrunner2sh=1
          pathtorunner2sh="$value"
          shift
          shift
          ;;
        --runner2sh-downward)
          runner2shdownward="$value"
          shift
          shift
          ;;
        --runner2sh-sas)
          runner2shsas="$value"
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

# Some checks on mandatory arguments

if [ $name = 0 ]; then
  if [ $filename = 0 ]; then
    echo "Either a name or a filename are needed to generate a slurm job."
    exit 2
  fi
fi

# Write out gdb.x.sh if needed / generate gdb.x / set $pathtogdbx and $hasgdbx

# Write out runner2.sh if needed / set $pathtorunner2sh and $hasrunner2sh

# Make runner2sh arguments
runner2shdownwardarg=""
if [ $runner2shdownward = 0 ]; then
  # ??
  runner2shdownwardarg=""
else
  runner2shdownwardarg="--downward $runner2shdownward"
fi
runner2shsasarg=""
if [ $runner2shsas = 0 ]; then
  # ??
  runner2shsasarg=""
else
  runner2shsasarg="--sas $runner2shsas"
fi
runner2shgdbxarg=""
if [ $hasgdbx = 0 ]; then
  # ??
  runner2shgdbxarg=""
else
  runner2shgdbxarg="--gdbx $pathtogdbx"
fi

# Check for all needed args

if [ $hasrunner2sh = 0 ]; then
  echo "No runner2.sh - possibly missing argument?"
  exit 2
fi

if [ -z $wallclock ]; then
  echo "No wallclock time set. Use --wallclock to set it."
  exit 3
fi

if [ -z $memory ]; then
  echo "No memory limit set. Use --memory to set it."
  exit 4
fi

# Write out slurm job

cat > $filename <<slurmjob
#!/bin/bash -e
#SBATCH --job-name=$name  # job name (shows up in the queue)
#SBATCH --time=$wallclock # Walltime (HH:MM:SS)
#SBATCH --mem=$memory     # Memory in MB

$pathtorunner2sh $runner2shdownwardarg $runner2shsasarg $runner2shgdbxarg

slurmjob

# Run the slurm job if needed

if [ $runimmediately = 1 ]; then
  sbatch $filename
fi

