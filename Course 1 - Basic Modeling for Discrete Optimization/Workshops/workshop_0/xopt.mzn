var 0..10: x;

constraint x mod 4 = 0;

solve minimize (x - 7) * (x - 7);

output ["The output of x is: " ++ show(x)]