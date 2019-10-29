int: T; % maximum time allowed;
set of int: TIME = 1..T;
set of int: TIME0 = 0..T;

int: E; % weight of elephant in STONES;
set of int: STONE = 0..E;

int: G; % number of guards
set of int: GUARD = 1..G;
array[GUARD] of STONE: easy;   
array[GUARD] of STONE: hard;
array[GUARD] of TIME: tired;

GUARD: p; % maximum people on pier;
GUARD: b; % maximum people on boat;

set of int: ACT = -1..E; % -1 = goto bank, 0 = wait, > 0 carry stones  
int: wait = 0;
int: to_bank = -1;
array[GUARD,TIME] of var ACT: act;        % action at time t
var TIME: end;                            % end time;

enum POS = { Bank, Boat };
 
array[GUARD, TIME0] of var POS: pos;
array[GUARD, TIME] of var bool: resting;

array[TIME0] of var STONE: sboat;


%array[GUARD, TIME] of var bool: testing;


% Setting initial states...
constraint forall(g in GUARD)(pos[g, 0] = Bank);
constraint forall(g in GUARD)(resting[g, 1] = false);
constraint sboat[0] = 0;

constraint forall(t in TIME, g in GUARD)(valid_move_action(pos[g, t-1], pos[g,t], act[g,t], resting[g,t]) /\ 
                                         (act[g,t] <= easy[g] \/ (act[g,t] <= hard[g] /\ forall(t2 in TIME where t2 in t+1..min(T, t+tired[g])) 
                                                                                              (resting[g, t2] = true)%act should be less easy or less than hard if   
                                                                                                                     %the guard rest after t
                                                                 )
                                         )
                                        );
                                         
predicate valid_move_action(var POS: from, var POS: to, var ACT: action, var bool: resting) = 
  (action = wait /\ to == from) \/ 
  (action = to_bank /\ from = Boat /\ to = Bank) \/ 
  (resting = false /\ action > 0 /\ from = Bank /\ to = Boat);

%Sum stones into sboat
constraint forall(t in TIME)(
                              sboat[t] = sum(g in GUARD)(if act[g,t] > 0 then act[g,t] else 0 endif) + sboat[t-1]
                            );

% % Limit # guards in pier
constraint forall(t in TIME)(
                              sum(g in GUARD)(abs(act[g,t]) > 0) <= p  
                          );


% Moving in the same direction
constraint forall(t in TIME)(
                              abs(sum(g in GUARD)(act[g,t])) == sum(g in GUARD)(abs(act[g,t]))                 
                            );        
                        
% Limit number guards on Boat at time t
constraint forall(t in TIME)(
                              sum(g in GUARD)(pos[g,t] = Boat) <= b
                            );
                            
% Actions after the end should be 0?
constraint forall(g in GUARD, t in TIME)(t >= end -> act[g,t] = 0);

% Final state
constraint sboat[end] >= E;


% output ["act = array2d(GUARD,TIME,\(act));\n"] ++
%        ["end = \(end-1);\n"];
% %     [4, -1, 1, -1, 1, -1, 1, 0, 0, 0
% %      9, -1, 9, -1, 9, -1, 6, 0, 0, 0]
% % [0, 13, 13, 23, 23, 33, 33, 40, 40, 40, 40]