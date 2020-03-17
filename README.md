# fast-downward-testing

This is a harness to run fast downward and measure the size of the open list during the course of a search.

## Installation

You will need a relatively recent gcc (7+), gdb (7+), and python (3.5+). Then git clone this repository somewhere on your system.

Run the included `gdb.x.sh` to generate a gdb.x file configured for your system. You will need to specify the location of the python gdb support library and the fast downward search strategy.

For example, a system with the python gdb support location at `/usr/share/gcc-data/x86_64-pc-linux-gnu/8.3.0/python/` and a search strategy of `--search "astar(lmcut())"` would need the following command to be run:

```
./gdb.x.sh --libcxxpath '/usr/share/gcc-data/x86_64-pc-linux-gnu/8.3.0/python/' --arguments '`--search "astar(lmcut())"'
```

## Usage

The `runner2.sh` shell file will run fast downward over a sas file and measure the size of the open list during the course of a search.

The location of the fast downward executable and the location of the sas file should be specified.

For example, if fast downward is at `/home/example-user/code/Fast-Downward-c9844230bcf2/builds/release/bin/downward` and the sas file you want to run is at `/home/example-user/code/Fast-Downward-c9844230bcf2/output.sas` you could run this ommand:

```
./runner2.sh --downward "/home/example-user/code/Fast-Downward-c9844230bcf2/builds/release/bin/downward" --sas "/home/example-user/code/Fast-Downward-c9844230bcf2/output.sas"
```

