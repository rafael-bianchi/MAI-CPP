array[int] of int: readings;
int: start;
int: n = length(readings);
set of int: HOUR = 1..n;
set of int: HOUR0 = 0..n;

array[HOUR0] of var 25..30: temp;
array[HOUR] of var 25..30: tp;
array[HOUR] of var CHOICE: history_choice;

constraint forall(h in HOUR)(tp[h] = temp[h]);

enum CHOICE = {heat, strongly_heat, cool, strongly_cool, do_nothing};
array[CHOICE] of int: change_temp = [1, 4, -2, -5, 0];
array[CHOICE] of int: costs = [1, 5, 3, 9, 0];

constraint temp[0] = start;
constraint forall(t in 1..n)(temp[t] = (readings[t] + temp[t-1]) div 2 
                                        + change_temp[history_choice[t]]);

var int: cost = sum(h in HOUR)(costs[history_choice[h]]);

solve minimize cost;

output ["temp = \(tp); \nchoice = \(history_choice);\ncost = \(cost);"];