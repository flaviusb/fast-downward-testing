#!/bin/bash

# So, we need a filename and a name and wallclock time and resources count for the slurm job
# And we also need to either pass through the arguments for gdb.x.sh and/or runner2.sh or we need to get the locations of the generated scripts
# Then we build the things that need building - and get those paths that way
# And generate the slurm script with the paths and fielname and name and wallclock time and etc
# And then we optionally run it if the run option is selected
