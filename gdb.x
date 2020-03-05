set language c++
# $internal_size_count_max is the number of elements the OpenList thinks it has
set $internal_size_count_max = 0
set pagination off
set print pretty on
set print object on
set print array on
set print array-indexes on

python
import gdb
import gdb.types
import re

class GrovelOpenLists (gdb.Command):
  """Grovel open lists, returning size in bytes"""

  def __init__ (self):
    super (GrovelOpenLists, self).__init__ ("grovel-openlist", gdb.COMMAND_DATA, gdb.COMPLETE_SYMBOL)

  def invoke (self, arg, from_tty):
    argv = gdb.string_to_argv(arg)
    if len(argv) == 1:
      size = self.grovel(gdb.parse_and_eval(argv[0]))
      print(size)
    else:
      print("grovel-openlist expects one argument")

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
    return 0

  def grovel_tbol(self, arg):
    return 0


GrovelOpenLists ()

end


rbreak ^[0-9a-zA-Z_::]*OpenList<[0-9a-zA-Z_<>]*>::.*$
commands
  #print *this
  grovel-openlist *this
  if (this.size > $internal_size_count_max)
    set $internal_size_count_max = this.size
  end
  continue
end

#continue

run --search "astar(lmcut())"

