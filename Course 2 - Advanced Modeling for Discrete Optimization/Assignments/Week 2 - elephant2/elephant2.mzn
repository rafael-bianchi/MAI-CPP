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
 
array[GUARD, TIME0] of var bool: pos; % True = Boat
                                      % False = Bank        
array[TIME0] of var STONE: sboat;

% Setting initial states...
constraint forall(g in GUARD)(pos[g, 0] = false);
constraint sboat[0] = 0;

constraint forall(t in TIME, g in GUARD)(
                                          let {var bool: from = pos[g,t-1];
                                               var bool: to = pos[g,t];
                                               var ACT: action = act[g,t];} in
                                            	 (action = wait <-> from = to) /\
                                            	 (action = to_bank -> from) /\
                                            	 (action > 0 -> to) /\ 
                                            	 (is_tired(g,t) -> action <= 0) /\
                                            	 action <= hard[g] 
                                        );

%Check if guard is tired at t time, looking r steps back and seeing if there is
% an action > than the easy one...
predicate is_tired(var GUARD: g, var TIME: t) =
let { var int: r = tired[g];
      var int: max_arr = 
      max([act[g, t2]*(t2 in max(1, t-r)..max(1, t-1)) 
          | t2 in TIME]); } in
max_arr > easy[g];
              
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
                              sum(g in GUARD)(pos[g,t]) <= b
                            );
                            
% Actions after the end should be 0?
constraint forall(g in GUARD, t in TIME)(t >= end -> act[g,t] = 0);

% Final state
constraint sboat[end] >= E;

solve minimize end;
output ["act = array2d(GUARD,TIME,\(act));\n"] ++
       ["end = \(end-1);\n"];
%     [4, -1, 1, -1, 1, -1, 1, 0, 0, 0
%      9, -1, 9, -1, 9, -1, 6, 0, 0, 0]
% [0, 13, 13, 23, 23, 33, 33, 40, 40, 40, 40]