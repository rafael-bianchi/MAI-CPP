% assignment 2
% select a set of raiding warrior
enum WARRIOR;
WARRIOR: dummy; 
enum CLAN; % the clan they belong too

int: l; % minimum raid party size
int: u; % maximum raid party size
int: m; % limit of hatreds

array[WARRIOR] of int: strength;
array[WARRIOR] of CLAN: clan;

array[CLAN,CLAN] of 0..1: hates;

array[1..u] of var WARRIOR: party;

constraint forall(i in 1..l)(party[i] > dummy);

constraint forall(i in 1..u-1)(party[i] >= party[i+1] + (party[i+1] != dummy));

constraint sum(i,j in 1..u where i < j)(hates[clan[party[i]],clan[party[j]]]) <= m;

solve maximize obj;

var int: obj = sum(i in 1..u)(strength[party[i]]);

output ["raid = "] ++
       ["{"] ++ [ if fix(party[j]) != dummy then 
                     show(party[j]) ++ if j == u \/ fix(party[j+1]) = dummy then "" else ", " endif 
                  else "" endif | j in 1..u ] ++ ["};\n"] ++
       ["obj = \(obj);\n"];