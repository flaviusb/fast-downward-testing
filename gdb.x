set language c++
# $internal_size_count_max is the number of elements the OpenList thinks it has
set $internal_size_count_max = 0
set $grovelled_size_max = 0
set pagination off
set print pretty on
set print object on
set print array on
set print array-indexes on

python
import gdb
import gdb.types
import re
import itertools


# So, C++ and gdb are bad
# I have not found a way to do this portably
# You will have to edit the path to libstdcxx manually
libcxxpath = '/usr/share/gcc-data/x86_64-pc-linux-gnu/8.3.0/python/'
import sys
import os
import os.path
sys.path.insert(0, libcxxpath)
import libstdcxx.v6

from libstdcxx.v6.printers import RbtreeIterator, get_value_from_Rb_tree_node, find_type

class GrovelOpenLists (gdb.Function):
  """Grovel open lists, returning size in bytes"""

  def __init__ (self):
    super (GrovelOpenLists, self).__init__ ("grovel")

  def invoke (self, arg):
    return self.grovel(arg)
    #size = 0
    #argv = gdb.string_to_argv(arg)
    #if len(argv) == 1:
    #  size = self.grovel(gdb.parse_and_eval(argv[0]))
    #  print(size)
    #else:
    #  print("grovel expects one argument")
    #return size

  def grovel(self, arg):
    # We dispatch based on type
    size = 0
    if arg.type.tag == "AlternationOpenList":
      size = self.grovel_aol(arg)
    elif arg.type.tag == "BestFirstOpenList":
      size = self.grovel_bfol(arg)
    elif arg.type.tag == "EpsilonGreedyOpenList":
      size = self.grovel_egol(arg)
    elif arg.type.tag == "ParetoOpenList":
      size = self.grovel_pol(arg)
    elif arg.type.tag == "tiebreaking_open_list::TieBreakingOpenList<StateID>":
      size = self.grovel_tol(arg)
    elif arg.type.tag == "TypeBasedOpenList":
      size = self.grovel_tbol(arg)
    else:
      print(f'Did not understand how to deal with object with tag {arg.type.tag}')
    return size

  def grovel_aol(self, arg):
    return 0

  def grovel_bfol(self, arg):
    return 0

  def grovel_egol(self, arg):
    return 0

  def grovel_pol(self, arg):
    return 0

  def grovel_tol(self, arg):
    # Get base size
    base_size = arg.type.sizeof
    # Now deal with the map<vecor<bitset>, deque<StateID>>
    buckets_size = 0
    buckets_base_size = arg['buckets'].type.sizeof
    bucket_iterator = RbtreeIterator(arg['buckets'])
    link_type = find_type(find_type(arg['buckets'].type, '_Rep_type'), '_Link_type')
    for node in bucket_iterator:
      real_node = node.cast(link_type).dereference()
      print(node)
      print(real_node)
      print(get_value_from_Rb_tree_node(real_node))
    evaluators_size = 0
    return (base_size + buckets_size + buckets_base_size + evaluators_size)

  def grovel_tbol(self, arg):
    return 0


GrovelOpenLists ()

end

set $internal_size_count_max = 0

rbreak ^[0-9a-zA-Z_::]*OpenList<[0-9a-zA-Z_<>]*>::.*$
commands
  #print *this
  #print this.size
  if (this.size > $internal_size_count_max)
    set $internal_size_count_max = this.size
  end
  print this.size
  #print $internal_size_count_max
  #print $grovel(*this)
  set $temp_grovel = $grovel(*this)
  if ($temp_grovel > $grovelled_size_max)
    set $grovelled_size_max = $temp_grovel
  end
  print $temp_grovel
  print $internal_size_count_max
  continue
end

clear TieBreakingOpenList<StateID>::TieBreakingOpenList

#continue

run --search "astar(lmcut())"

