set language c++
set $basic_sizes_max = 0
set pagination off
set print pretty on
set print object on
set print array on
set print array-indexes on

rbreak ^[0-9a-zA-Z_::]*OpenList<[0-9a-zA-Z_<>]*>::.*$
commands
  #print *this
  if (this.size > $basic_sizes_max)
    set $basic_sizes_max = this.size
  end
  continue
end

#continue

#run ~/code/Fast-Downward-c9844230bcf2/output.sas

run --search "astar(lmcut())"

