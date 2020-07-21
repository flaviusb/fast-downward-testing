#!/bin/bash


libcxxpath='/usr/share/gcc-data/x86_64-pc-linux-gnu/8.3.0/python/'
arguments='--search "astar(lmcut())"'
out='data.txt'
gdbx="gdb.x"

usage() { cat <<HELP
gdb.x.sh: Generates a gdb.x command set.
Options:
  --libcxxpath  PATH
  --arguments   QUOTED FAST DOWNWARD SEARCH STRING
  --dataout     PATH
  --gdbxname    PATH

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
      --libcxxpath)
        libcxxpath="$value"
        shift
        shift
        ;;
      --arguments)
        arguments="$value"
        shift
        shift
        ;;
      --dataout)
        out="$value"
        shift
        shift
        ;;
      --gdbxname)
        gdbx="$value"
        shift
        shift
        ;;
      *)
        echo "I don't understand: $opt"
        exit 1
        ;;
    esac
done



cat > "$gdbx" <<blerg
set language c++
# \$internal_size_count_max is the number of elements the OpenList thinks it has
set \$internal_size_count_max = 0
set \$grovelled_size_max = 0
set pagination off
set print pretty on
set print object on
set print array on
set print array-indexes on
set print inferior-events off
# This is not available on gdb 8.3 apparently
#  set print frame-info short-location
set print entry-values no
set print frame-arguments none

python
import gdb
import gdb.types
import re
import itertools


# So, C++ and gdb are bad
# I have not found a way to do this portably
# You will have to edit the path to libstdcxx manually
libcxxpath = "$libcxxpath"
import sys
import os
import os.path
sys.path.insert(0, libcxxpath)
import libstdcxx.v6

from libstdcxx.v6.printers import RbtreeIterator, get_value_from_Rb_tree_node, find_type, StdVectorPrinter, StdDequePrinter, SharedPointerPrinter

class LogThing (gdb.Function):
  """Write internal and grovelled sizes out"""

  def __init__(self):
    super (LogThing, self).__init__ ("logdata")

  def invoke (self, out, internal, internal_grovelled, grovelled, grovelled_internal):
    internal_string = str(internal)
    grovelled_string = str(grovelled)
    internal_grovelled_string = str(internal_grovelled)
    grovelled_internal_string = str(grovelled_internal)
    message = f"Max Abstract Size (elements): {internal_string}\\nGrovelled concrete Size for that (bytes): {internal_grovelled_string}\\nMax Grovelled concrete Size (bytes): {grovelled_string}\\nAbstract Size for that (elements): {grovelled_internal_string}\\n"
    with open(str(out), "w") as fd:
      fd.write(message)
    return f"Logged: {message} to {out}"

LogThing ()

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
    if arg.type.tag == "alternation_open_list::AlternationOpenList<StateID>":
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
    # AlternationOpenLists have 2 stl containers inside: ⌜open_lists: vector<unique_ptr<OpenList<Entry>>>⌝ and ⌜priorities: vector<int>⌝
    base_size = arg.type.sizeof
    recursive_openlists_size = 0
    ol_vec = StdVectorPrinter('unique_ptr<OpenList<StateID>>', arg['open_lists']).children()
    for indirect_node in ol_vec:
      recursive_openlists_size += indirect_node[1].type.sizeof
      uptr = UniquePointerPrinter('OpenList<StateID>', indirect_node[1]).children()
      for direct_node in uptr:
        recursive_openlists_size += self.grovel(direct_node)
    priorities_size = 0
    prio_vec = StdVectorPrinter('int', arg['priorities']).children()
    for num in children:
      priorities_size += num.type.sizeof
    return (base_size + recursive_openlists_size + priorities_size)

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
      # Add node pointer size
      buckets_size += node.type.sizeof
      real_node = node.cast(link_type).dereference()
      buckets_size += real_node.type.sizeof
      #print(node)
      #print(real_node)
      #print(get_value_from_Rb_tree_node(real_node))
      pair = get_value_from_Rb_tree_node(real_node)
      key = pair['first']
      item = pair['second']
      # Key is a vector<int>, which means the size is the size of 'key' plus the size of the inner storage array,
      # as the ints are stored directly rather than as pointers
      # For the moment we use a StdVectorPrinter though, as size (and in cxx11, capacity) are optimised out
      key_vec = StdVectorPrinter('int', key).children()
      for node in key_vec:
        buckets_size += node[1].type.sizeof
      buckets_size += key.type.sizeof
      # item is a deque<StateID> and Deques make no guarantees on how their storage is implemented; we have to grovel through to be sure
      item_vec = StdDequePrinter('StateID', item).children()
      for node in item_vec:
        buckets_size += node[1].type.sizeof
      buckets_size += item.type.sizeof
      #print(key)
      #print(item)
    evaluators_size = 0
    evaluators_size += arg['evaluators'].type.sizeof
    evaluators_vec = StdVectorPrinter('shared_ptr<Evaluator>', arg['evaluators']).children()
    for node in evaluators_vec:
      evaluators_size += node[1].type.sizeof
      sptr = SharedPointerPrinter('Evaluator', node[1]).children()
      for ptr in sptr:
        evaluators_size += ptr[1].dereference().type.sizeof
    return (base_size + buckets_size + buckets_base_size + evaluators_size)

  def grovel_tbol(self, arg):
    return 0


GrovelOpenLists ()

end

set \$internal_size_count_max = 0
set \$grovelled_size_at_max_internal_size = 0
set \$grovelled_size_max = 0
set \$internal_size_count_at_max_grovelled_size = 0
set \$spins = 0
set \$spins_10ks = 0

rbreak ^[0-9a-zA-Z_::]*OpenList<[0-9a-zA-Z_<>]*>::do_insertion.*\$
commands
  #print *this
  #print this.size
  set \$temp_grovel = \$grovel(*this)
  if (this.size > \$internal_size_count_max)
    set \$internal_size_count_max = this.size
    set \$grovelled_size_at_max_internal_size = \$temp_grovel
  end
  #printf "Current abstract size of open list: %u\n", this.size
  #print \$internal_size_count_max
  #print \$grovel(*this)
  #printf "Current approximate concrete size of open list (in bytes): %u\n", \$temp_grovel
  if (\$temp_grovel > \$grovelled_size_max)
    set \$grovelled_size_max = \$temp_grovel
    set \$internal_size_count_at_max_grovelled_size = this.size
  end
  if (\$spins == 10000)
    set \$spins = 0
    set \$spins_10ks = \$spins_10ks + 1
    printf "Max Abstract Size (elements): %u \nGrovelled concrete Size for that (bytes): %u \nMax Grovelled concrete Size (bytes): %u \nAbstract Size for that (elements): %u \nCurrent Abstract Size (elements) %u \nCurrent gravelled concrete size (bytes) %u\nCurrent spins * 10k: %u \n", \$internal_size_count_max, \$grovelled_size_at_max_internal_size, \$grovelled_size_max, \$internal_size_count_at_max_grovelled_size, this.size, \$temp_grovel, \$spins_10ks
  else
    set \$spins = \$spins + 1
  end
  #printf "Maximum abstract size of open list: %u\n", \$internal_size_count_max
  #printf "Maximum approximate concrete size of open list (in bytes): %u\n", \$grovelled_size_max
  #print \$logdata("$out", \$internal_size_count_max, \$grovelled_size_max)
  continue
end

break exit
commands
  print \$logdata("$out", \$internal_size_count_max, \$grovelled_size_at_max_internal_size, \$grovelled_size_max, \$internal_size_count_at_max_grovelled_size)
  continue
end

#clear TieBreakingOpenList<StateID>::TieBreakingOpenList

#continue

run $arguments
blerg

