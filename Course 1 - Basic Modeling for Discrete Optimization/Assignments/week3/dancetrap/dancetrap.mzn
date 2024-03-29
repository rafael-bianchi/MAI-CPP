% Beauty Trap
% Perform the most seductive dance

enum LEGS = {spin, leap, waltz, curtsey, prep, stand};
enum ARMS = {beckon, out, up, wrapped, neutral};
enum FACE = {smile, wink, batt, think, glow, blank};

int: maxlen;
set of int: STEP = 1..maxlen;
array[LEGS] of int: maxlegs;
array[ARMS] of int: maxarms;
array[FACE] of int: maxface;
constraint assert(maxlegs[stand] >= maxlen, "maxlegs[stand] smaller than maxlen");
constraint assert(maxarms[neutral] >= maxlen, "maxarms[neutral] smaller than maxlen");
constraint assert(maxface[blank] >= maxlen, "maxface[blank] smaller than maxlen");
array[LEGS,ARMS] of int: dance_value;
array[ARMS,FACE] of int: entice_value;
constraint assert(dance_value[stand,neutral] = 0, "incorrect dance_value array");
constraint assert(entice_value[neutral,blank] = 0, "incorrect entice_value array");
int: boredom; % how bored each step make the viewer

var STEP: len;
array[STEP] of var LEGS: legs;
array[STEP] of var ARMS: arms;
array[STEP] of var FACE: face;

include "regular.mzn";

%Leg constraints
constraint regular(legs, 7, 6, tl, 1, {2,3,4,5,6,7});
array[1..7, LEGS] of 0..7: tl=
     [|2,0,4,5,6,7 % 1 start
      |2,0,0,5,6,7 % 2 spin
      |2,0,4,0,0,7 % 3 leap
      |2,0,4,0,6,7 % 4 waltz
      |2,0,4,5,0,7 % 5 curtsey
      |2,3,4,5,6,7 % 6 prep
      |2,0,4,5,6,7 |]; % 7 stand

constraint forall(i in LEGS)(sum(j in 1..maxlen)(legs[j] = LEGS[i]) <= maxlegs[i]);
constraint forall(i in 1..maxlen-3)(legs[i] = waltz /\ legs[i+1] = waltz /\ legs[i+2] = waltz -> legs[i+3] != waltz);
constraint forall(i in 1..maxlen-1)
                 ((LEGS[legs[i]] = waltz ->
                 forall(j in i+1..len)
                       (LEGS[legs[j]] = curtsey ->
                        exists(k in i+1..j-1)(LEGS[legs[k]] = stand))));
constraint forall(i in len+1..maxlen)
                 (legs[i] = stand);

%Arms constraints
constraint regular([ARMS[arms[i]] | i in STEP], 6, 5, ta, 1, {2,3,4,5,6});
array[1..6, ARMS] of 0..6: ta=
     [|0,3,4,5,6 % 1 start
      |0,3,4,5,6 % 2 beckon
      |2,0,4,0,6 % 3 out
      |2,3,0,0,6 % 4 up
      |0,3,4,0,6 % 5 wrapped
      |0,3,4,5,6 |];% 6 neutral

constraint forall(i in ARMS)(sum(j in 1..maxlen)(arms[j] = ARMS[i]) <= maxarms[i]);
constraint forall(i in len+1..maxlen)
                 (arms[i] = neutral);

%Facial constraints 
constraint regular([FACE[face[i]] | i in STEP], 7, 6, tf, 1, {2,3,4,5,6,7});
array[1..7, FACE] of 0..7: tf =
[| 2, 3, 4, 5, 6, 7      % 1 Start
 | 0, 3, 4, 0, 6, 7      % 2 Smile
 | 2, 0, 4, 5, 6, 7      % 3 Wink
 | 2, 3, 0, 0, 6, 7      % 4 Batt
 | 2, 3, 4, 0, 6, 7      % 5 Think
 | 2, 3, 4, 5, 0, 7      % 6 Glow
 | 2, 3, 4, 5, 6, 7 |];  % 7 Blank

constraint forall(i in FACE)(sum(j in 1..maxlen)(face[j] = FACE[i]) <= maxface[i]);
constraint forall(i in len+1..maxlen)
                 (face[i] = blank);

var int: obj; 
constraint obj = sum(i in 1..len)(dance_value[legs[i], arms[i]] + entice_value[arms[i], face[i]])
               - boredom * len; 

solve maximize obj;

output ["len = ", show(len), ";\n" ++
        "legs = ", show(legs), ";\n" ++
        "arms = ", show(arms), ";\n" ++
        "face = ", show(face), ";\n" ++
        "obj = ", show(obj),";"];


