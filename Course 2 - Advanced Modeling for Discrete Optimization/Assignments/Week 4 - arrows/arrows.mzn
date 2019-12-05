int: length; % height of lake
set of int: LENGTH = 0..length-1;
int: width; % width of lake
set of int: WIDTH = 0..width-1;

int: ntypes;  % number of types of ship
set of int: TYPE = 1..ntypes;
array[TYPE] of int: number;         % number of each type of ship
array[TYPE] of set of SHAPE: config; % configs for each type of ship

int: nshapes; % number of shapes
set of int: SHAPE = 1..nshapes;
set of int: SHAPE0 = 0..nshapes;
array[SHAPE] of set of ROFF: shape;

int: nroff; % number of rectangle offsets
set of int: ROFF = 1..nroff;
array[ROFF,1..4] of int: rectoff; % x offset, y offset, width, height

int: total_ships = sum(number);
set of int: SHIP = 1..total_ships;
array[SHIP] of var LENGTH:  x;
array[SHIP] of var WIDTH:   y;
array[SHIP] of var SHAPE0:  k;

array[LENGTH] of WIDTH: mist; % mist starts at this width, goes downward
array[WIDTH] of int: arrow;  % number of arrows that arrive at this height
array[TYPE] of int: price;
int: budget;
enum STAGE = {A,B,C,D,E,F};
STAGE: stage;

bool: stage_A;
bool: stage_B;
bool: stage_C;
bool: stage_E;
bool: stage_F;
bool: stage_D;

stage_A = (stage = A);
stage_B = (stage = B);
stage_C = (stage = C);
stage_E = (stage = E);
stage_F = (stage = F);
stage_D = (stage = D);

var int: tarrows;

% At this stage you can ignore the mist, arrow, price and budget data. The stage variable will be A.

constraint stage_A -> forall(sp in SHIP)(k[sp] = 1);
constraint stage_A -> tarrows = 0;

constraint stage_A -> forall(sp in SHIP)(x[sp] + rectoff[shipType[sp], 3] < length);
constraint stage_A -> forall(sp in SHIP)(y[sp] + rectoff[shipType[sp], 4] < width);
constraint stage_A -> forall(sp1, sp2 in SHIP where sp1 < sp2)(x[sp1] >= x[sp2] + rectoff[shipType[sp2], 3] \/ 
                                                               x[sp2] >= x[sp1] + rectoff[shipType[sp1], 3] \/
                                                               y[sp1] >= y[sp2] + rectoff[shipType[sp2], 4] \/ 
                                                               y[sp2] >= y[sp1] + rectoff[shipType[sp1], 4]);
                                                               
constraint stage_A -> forall(sp1, sp2 in SHIP where sp1 < sp2 /\ shipType[sp1] = shipType[sp2])((x[sp1] = x[sp2] /\ y[sp1] > y[sp2]) \/ (x[sp1] > x[sp2]));

%In stage B we will consider more realistic boat shapes, but still not consider rotations. 
%You can continue to ignore the mist, arrow, price and budget data.

constraint stage_B -> tarrows = 0;
constraint stage_B -> forall(sp in SHIP)(k[sp] = 1);

% bool: stage_A;
% stage_A = (stage = A);
% constraint stage_A -> forall(sp in SHIP)(k[sp] = 1);
% constraint stage_A -> tarrows = 0;

constraint stage_B -> forall(sp in SHIP)(
                        forall(s in shape[shipType[sp]])(
                        x[sp] + rectoff[s, 1] + rectoff[s, 3] <= length /\
                        y[sp] + rectoff[s, 2] + rectoff[s, 4] <= width));
constraint stage_B -> forall(sp1, sp2 in SHIP where sp1 < sp2)(forall(s1 in shape[shipType[sp1]], s2 in shape[shipType[sp2]])(
                                                                        x[sp1] + rectoff[s1,1] >= x[sp2] + rectoff[s2,1] + rectoff[s2,3] \/ 
                                                                        x[sp2] + rectoff[s2,1] >= x[sp1] + rectoff[s1,1] + rectoff[s1,3] \/
                                                                        y[sp1] + rectoff[s1,2] >= y[sp2] + rectoff[s2,2] + rectoff[s2,4] \/ 
                                                                        y[sp2] + rectoff[s2,2] >= y[sp1] + rectoff[s1,2] + rectoff[s1,4]));

constraint stage_B -> forall(sp1, sp2 in SHIP where sp1 < sp2 /\ shipType[sp1] = shipType[sp2])((x[sp1] = x[sp2] /\ y[sp1] > y[sp2]) \/ (x[sp1] > x[sp2]));

%In stage C we will take into account the position of the mist on the river. 

constraint stage_C -> tarrows = 0;
constraint stage_C -> forall(sp in SHIP)(k[sp] = 1);
constraint stage_C -> forall(sp in SHIP)(forall(s in shape[shipType[sp]])(x[sp] + rectoff[s, 1] + rectoff[s, 3] <= length /\
                                                                            y[sp] + rectoff[s, 2] + rectoff[s, 4] <= width));
constraint stage_C -> forall(sp1, sp2 in SHIP where sp1 < sp2)(
    forall(s1 in shape[shipType[sp1]], s2 in shape[shipType[sp2]])(
    x[sp1] + rectoff[s1,1] >= x[sp2] + rectoff[s2,1] + rectoff[s2,3] \/ 
    x[sp2] + rectoff[s2,1] >= x[sp1] + rectoff[s1,1] + rectoff[s1,3] \/
    y[sp1] + rectoff[s1,2] >= y[sp2] + rectoff[s2,2] + rectoff[s2,4] \/ 
    y[sp2] + rectoff[s2,2] >= y[sp1] + rectoff[s1,2] + rectoff[s1,4]));

constraint stage_C -> forall(sp1, sp2 in SHIP where sp1 < sp2 /\ shipType[sp1] = shipType[sp2])((x[sp1] = x[sp2] /\ y[sp1] > y[sp2]) \/ (x[sp1] > x[sp2]));

%Each of the boats must
% be hidden under the mist. The mist array shows the height at which the mist begins
constraint stage_C -> forall(l in LENGTH, sh in SHIP)(
                            forall(s in shape[shipType[sh]])(x[sh] + rectoff[s,1] > l \/
                                                             x[sh] + rectoff[s,1] + rectoff[s,3] < l \/
                                                             y[sh] + rectoff[s,2] >= mist[l]));



constraint stage_D -> forall(sp in SHIP)(k[sp] = shipType[sp]);
constraint stage_D -> forall(sp in SHIP)(
                        forall(s in shape[shipType[sp]])(
                        x[sp] + rectoff[s, 1] + rectoff[s, 3] <= length /\
                        y[sp] + rectoff[s, 2] + rectoff[s, 4] <= width));
constraint stage_D -> forall(sp1, sp2 in SHIP where sp1 < sp2)(
                        forall(s1 in shape[shipType[sp1]], s2 in shape[shipType[sp2]])(
                                x[sp1] + rectoff[s1,1] >= x[sp2] + rectoff[s2,1] + rectoff[s2,3] \/ 
                                x[sp2] + rectoff[s2,1] >= x[sp1] + rectoff[s1,1] + rectoff[s1,3] \/
                                y[sp1] + rectoff[s1,2] >= y[sp2] + rectoff[s2,2] + rectoff[s2,4] \/ 
                                y[sp2] + rectoff[s2,2] >= y[sp1] + rectoff[s1,2] + rectoff[s1,4]));
constraint stage_D -> forall(sp1, sp2 in SHIP where sp1 < sp2 /\ shipType[sp1] = shipType[sp2])(
                        (x[sp1] = x[sp2] /\ y[sp1] > y[sp2]) \/ (x[sp1] > x[sp2]));

%Each of the boats must
% be hidden under the mist. The mist array shows the height at which the mist b
constraint stage_D -> forall(l in LENGTH, sh in SHIP)(
                            forall(s in shape[shipType[sh]])(x[sh] + rectoff[s,1] > l \/
                                                             x[sh] + rectoff[s,1] + rectoff[s,3] < l \/
                                                             y[sh] + rectoff[s,2] >= mist[l]));
constraint stage_D -> tarrows = sum(sp in SHIP)(sum(s in shape[shipType[sp]])(sum(tmpY in 0..rectoff[s,4]-1)(arrow[y[sp]+rectoff[s,2]+tmpY]*rectoff[s,3])));

%In stage E we will allow rotation and other reconfiguration of the boats. Now each boat will have
%a set of possible configurations representing rotations or other reconfiguration.
%You can continue to ignore the price and budget data.


array[SHIP] of var SHAPE:  k_start_1;

constraint stage_E ->
geost_bb(2, rsize, roff, shape, coord, k_start_1, [0,0], [length, width]);
constraint stage_E -> forall(sp1, sp2 in SHIP where sp1 < sp2 /\ shipType[sp1] = shipType[sp2])(
                        (x[sp1] = x[sp2] /\ y[sp1] > y[sp2]) \/ (x[sp1] > x[sp2]));

%Each of the boats must
% be hidden under the mist. The mist array shows the height at which the mist b
constraint stage_E -> forall(l in LENGTH, sp in SHIP, s in shape[k_start_1[sp]])(
                               x[sp] + rectoff[s,1] > l \/
                               x[sp] + rectoff[s,1] + rectoff[s,3] <= l \/
                               y[sp] + rectoff[s,2] >= mist[l]);
                               
constraint stage_E -> tarrows = sum(sp in SHIP, s in shape[k_start_1[sp]], recY in 0..rectoff[s,4]-1)(arrow[y[sp]+rectoff[s,2]+recY]*rectoff[s,3]);

constraint stage_E -> forall(sp in SHIP)(k_start_1[sp] in config[shipType[sp]]);

%In stage F we will take into account the limits of the budget. Zhuge Liang can only afford a certain
%number of boats, for each boat of type t he must pay price[t] up to the limit of budget.
%The output for stage F now needs to have meaningful answers for the x, y and k variables. The
%k array holds the shape selected for each ship from the configurations available for its type, or 0 if
%the ship is not used. An unused ship can have any coordinates. The tarrows amount should be the
%correct value. The answer should be a correct packing of the ships into the river with no overlap,
%and under the mist.


include "geost.mzn";

constraint stage_F ->
geost_bb(2, rsize0, roff0, shape0, coord, kind0, [0,0], [length, width]);

constraint stage_F -> forall(sp1, sp2 in SHIP where sp1 < sp2 /\ shipType[sp1] = shipType[sp2])(
                        if k[sp1] = 0 \/ k[sp2] = 0 then true else
                        (x[sp1] = x[sp2] /\ y[sp1] > y[sp2]) \/ (x[sp1] > x[sp2]) endif);

constraint stage_F -> forall(l in LENGTH)(
                           forall(sp in SHIP)(if k[sp] = 0 then true else
                              forall(s in shape[k[sp]])(
                                     x[sp] + rectoff[s,1] > l \/
                                     x[sp] + rectoff[s,1] + rectoff[s,3] <= l \/
                                     y[sp] + rectoff[s,2] >= mist[l]) endif));
                                     
constraint stage_F -> sum(sp in SHIP where k[sp]!=0)(price[shipType[sp]]) <= budget;

constraint stage_F -> forall(sp in SHIP)(k[sp] in config[shipType[sp]] \/ k[sp] = 0);
constraint stage_F -> tarrows = sum(sp in SHIP where k[sp] != 0, s in shape[k[sp]], tmpY in 0..rectoff[s,4]-1)(
                                          arrow[y[sp]+rectoff[s,2]+tmpY]*rectoff[s,3]);

% set the x,y base of unused ship to zero
constraint stage = F -> forall(sp in SHIP where k[sp] = 0)(x[sp] = 0 /\ y[sp] = 0);

% all stages
array[ROFF, 1..2] of int: rsize = array2d(ROFF, 1..2, [rectoff[i,j]|i in ROFF, j in 3..4]);
array[ROFF, 1..2] of int: roff = array2d(ROFF, 1..2, [rectoff[i,j]|i in ROFF, j in 1..2]);

array[SHIP, 1..2] of var int: coord;
constraint forall(i in SHIP)(coord[i,1] = x[i] /\ coord[i,2] = y[i]);

array[SHIP] of var TYPE: shipType;
constraint forall(sh in 1..total_ships)(
    if sh = 1 then
       shipType[sh] = 1
    elseif sum(tp in 1..shipType[sh-1])(number[tp]) >= sh then
    shipType[sh] = shipType[sh-1] 
    else shipType[sh] = shipType[sh-1] + 1 endif);


array[1..nroff+1, 1..2] of int: rsize0 = array2d(1..nroff+1, 1..2, [if i <= nroff then rectoff[i,j] else 0 endif|i in 1..nroff+1, j in 3..4]);

array[1..nroff+1, 1..2] of int: roff0 = array2d(1..nroff+1, 1..2, [if i <= nroff then rectoff[i,j] else 0 endif|i in 1..nroff+1, j in 1..2]);

array[1..nshapes+1] of set of 1..nroff+1: shape0 = [if i <= nshapes then shape[i] else {nroff+1} endif|i in 1..nshapes+1];

array[SHIP] of var 1..nshapes+1:  kind0;
constraint stage = stage_F -> forall(sp in SHIP)(if k[sp] = 0 then kind0[sp] = nshapes+1
                                            else kind0[sp] = k[sp] endif);

solve maximize tarrows;

output ["x = \(x);\n"]++
       ["y = \(y);\n"]++
       ["k = \(k);\n"] ++ 
       ["tarrows = \(tarrows);"];
