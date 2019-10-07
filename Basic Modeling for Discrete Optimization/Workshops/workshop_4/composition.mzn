int: n = 8;

set of int: NOTES = 1..n;

array[1..n] of var NOTES: order;
array[1..n-1] of var 1..n-1: diffe;


include "alldifferent.mzn";
constraint alldifferent(order);
constraint alldifferent(diffe);
constraint forall(i in 1..n-1)
                 (diffe[i] = abs(order[i+1] - order[i]));
solve satisfy;
output [ "order = " ++ show(order)];