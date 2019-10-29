int: T; % maximum time allowed;
set of int: TIME = 1..T;

int: G; %number of guards
int: F; 
int: W;

array[TIME] of var -F..F: move_food;     % move food +ve bank to boat, -ve boat to bank
array[TIME] of var -W..W: move_water;     % move water +ve bank to boat, -ve boat to bank

var TIME: end;

set of int: TIME0 = 0..T;
array[TIME0] of var 0..F: fboat;
array[TIME0] of var 0..W: wboat;

enum POS = { Bank, Boat };
array[TIME0] of var POS: pos;

predicate move(var 0..F: fhere, var 0..W: wrhere) =
               let {var 0..F: fthere = F - fhere,
                    var 0..W: wrthere = W - wrhere; } in
               (wrthere = fthere /\ fthere > fhere /\ wrthere > wrhere);
               
constraint pos[0] = Bank;
constraint fboat[0] = 0;
constraint wboat[0] = 0;

constraint forall(t in TIME)(fboat[t] = move_food[t] + fboat[t-1]);
constraint forall(t in TIME)(wboat[t] = move_water[t] + wboat[t-1]);

constraint forall(t in TIME)
                 (abs(move_food[t]) + abs(move_water[t]) <= G);

constraint forall(t in TIME)
%                  (if move_food[t] > 0 then move_water[t] >= 0
%                   else true endif /\
%                   if move_food[t] < 0 then move_water[t] <= 0
%                   else true endif);
                 (move_food[t] * move_water[t] >= 0);

array[POS] of POS: opp = {Boat, Bank};

predicate elephant(var POS: now, var 0..F: fhere, var 0..W: wrhere,
                   var POS: next) = 
%                    if move(fhere, wrhere) then
%                       next = if now = Bank then Boat else Bank endif
%                    else
%                      next = now
%                    endif;
                   next = [now, opp[now] ][move(fhere, wrhere) + 1] /\
                   (fhere = 0 <-> wrhere = 0);

constraint forall(t in TIME)
            (let { var 0..F: fhere = [F - fboat[t-1], fboat[t-1]][pos[t-1]];
                   var 0..W: wrhere = [W - wboat[t-1], wboat[t-1]][pos[t-1]]; } in
             elephant(pos[t-1], fhere, wrhere, pos[t]));
             

constraint forall(t in TIME)
                 (t > end -> move_water[t] = 0 /\ move_food[t] = 0);
constraint pos[end] = Boat /\ fboat[end] = 0 /\ wboat[end] = 0;

solve s;

% move_food = [0, 3, -2, -1, 0,0,0,0,0,0];
% move_water = [3, 0, -1, -2, 0,0,0,0,0,0];
% end = 4;