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

%constraint regular([LEGS[legs[i]] | i in STEP], 7, 6, tl, 1, {7});
%array[1..7,LEGS] of 0..7: tl =     [|

%Leg constraints
constraint forall(i in LEGS)(sum(j in 1..maxlen)(legs[j] = LEGS[i]) <= maxlegs[i]);
constraint forall(i in 1..maxlen)
                 (LEGS[legs[i]] = leap -> LEGS[legs[i-1]] = prep);
constraint forall(i in 1..maxlen-1)(LEGS[legs[i]] = spin -> 
                                    LEGS[legs[i+1]] in { curtsey, prep, stand });
constraint forall(i in 1..maxlen-1)(LEGS[legs[i]] = leap -> 
                                    LEGS[legs[i+1]] in { spin, waltz, stand });
constraint forall(i in 1..maxlen-3)
                 (LEGS[legs[i]] = waltz /\ LEGS[legs[i+1]] = waltz /\ LEGS[legs[i+2]] = waltz-> 
                  LEGS[legs[i+3]] != waltz);
constraint forall(i in 1..maxlen-1)(LEGS[legs[i]] = curtsey -> 
                                    LEGS[legs[i+1]] in { spin, leap, waltz, curtsey, stand });
constraint forall(i in 1..maxlen-1)
                 ((LEGS[legs[i]] = waltz ->
                 forall(j in i+1..maxlen)
                       (LEGS[legs[j]] = curtsey ->
                        exists(k in i+1..j-1)(LEGS[legs[k]] = stand))));
%Arms constraints
constraint forall(i in 2..maxlen)
                 (ARMS[arms[i]] = beckon -> ARMS[arms[i-1]] in { out, up });
constraint forall(i in 1..maxlen-1)
                 (ARMS[arms[i]] = wrapped -> i = 1 \/ ARMS[arms[i-1]] in { beckon, neutral });
constraint forall(i in 1..maxlen-1)(ARMS[arms[i]] != ARMS[arms[i+1]] \/ ARMS[arms[i]] = neutral);

%Facial constraints 
constraint forall(i in 1..maxlen-1)(FACE[face[i]] != FACE[face[i+1]] \/ FACE[face[i]] = blank);
constraint forall(i in 1..maxlen-1)(FACE[face[i]] in {smile, batt} -> 
                                    FACE[face[i+1]] in {smile, wink, batt, glow, blank});


var int: obj = sum(i in 1..len)(dance_value[legs[i], arms[i]] + entice_value[arms[i], face[i]])
               - boredom * len; 

solve maximize obj;

%After the dance ends she must stay in the base position stand, neutral, and blank.
%constraint legs[maxlen] = stand;
%constraint arms[maxlen] = neutral;
%constraint face[maxlen] = blank;


