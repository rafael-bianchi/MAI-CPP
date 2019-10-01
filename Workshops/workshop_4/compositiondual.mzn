int: n = 11;

set of int: NOTES = 1..n;

array[1..n] of var NOTES: order;
array[1..n-1] of var 1..n-1: diffs;
array[1..n] of var 1..n: posn;
array[1..n-1] of var 1..n-1: dposn;

include "inverse.mzn";
constraint inverse(order, posn);
constraint inverse(diffs, dposn);
constraint forall(i in 1..n-1)
                 (diffs[i] = abs(order[i+1] - order[i]));

constraint abs(posn[1] - posn[n]) = 1;

solve satisfy;
output [ "order = " ++ show(order)];