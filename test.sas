begin_version
3
end_version
begin_metric
0
end_metric
3
begin_variable
var0
-1
2
Atom free
Atom carry
end_variable
begin_variable
var1
-1
2
Atom ball-at(rooma)
Atom ball-at(roomb)
end_variable
begin_variable
var2
-1
2
Atom robot-at(rooma)
Atom robot-at(roomb)
end_variable
0
begin_state
0
0
1
end_state
begin_goal
2
0 0
1 1
end_goal
8
begin_operator
pick up rooma
3
0 0
1 0
2 0
1
0 0 -1 1
end_operator
begin_operator
pick up roomb
3
0 0
1 1
2 1
1
0 0 -1 1
end_operator
begin_operator
drop rooma
3
0 1
1 0
2 0
1
0 0 -1 0
end_operator
begin_operator
drop roomb
3
0 1
1 1
2 1
1
0 0 -1 0
end_operator
begin_operator
move rooma to roomb free
2
0 0
2 0
1
0 2 -1 1
end_operator
begin_operator
move roomb to rooma free
2
0 0
2 1
1
0 2 -1 0
end_operator
begin_operator
move rooma to roomb carry
3
0 1
1 0
2 0
1
0 1 -1 1
0 2 -1 1
end_operator
begin_operator
move roomb to rooma carry
3
0 1
1 1
2 1
1
0 1 -1 0
0 2 -1 0
end_operator
0
