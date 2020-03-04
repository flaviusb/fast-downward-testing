set language c++
# $internal_size_count_max is the number of elements the OpenList thinks it has
set $internal_size_count_max = 0
set pagination off
set print pretty on
set print object on
set print array on
set print array-indexes on

rbreak ^[0-9a-zA-Z_::]*OpenList<[0-9a-zA-Z_<>]*>::.*$
commands
  #print *this
  if (this.size > $basic_sizes_max)
    set $internal_size_count_max = this.size
  end
  continue
end

#continue

run --search "astar(lmcut())"

