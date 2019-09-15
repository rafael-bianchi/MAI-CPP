int: n = 5;
int: start = 25;

array[1..n] of int: readings = [35,35,20,20,20];

array[0..n] of var int: temp;

constraint temp[0] = start;
constraint forall(i in 1..n)(temp[i] = ((readings[i]+temp[i-1]) div 2));

solve satisfy;