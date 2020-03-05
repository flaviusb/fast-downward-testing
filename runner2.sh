#!/bin/bash

downward=`ls ~/code/Fast-Downward-c9844230bcf2/builds/release/bin/downward`
sas=`ls ~/code/Fast-Downward-c9844230bcf2/output.sas`
cat "$sas" | gdb -se="$downward" -x gdb.x
#gdb -se="$downward" -x gdb.x
