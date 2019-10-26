int: n; % number of court members
set of int: COURT = 1..n;
int: emperor = 1;
array[COURT] of int: rank;
array[COURT] of int: ability;

int: m; % number of horses
set of int: HORSE = 1..m;
array[HORSE] of int: beauty;
array[HORSE] of int: speed;

array[COURT,HORSE] of int: enjoy;

set of int: COURT0 = 0..n;
set of int: HORSE0 = 0..m;
int: max_riding = min(m, n);

array[COURT] of var HORSE0: horse;
array[HORSE] of var COURT0: court;


%The emperor must enjoy the day more than anyone else
constraint forall(i in COURT)(i != emperor /\ horse[i] > 0 -> enjoy[i,horse[i]] < enjoy[emperor,horse[emperor]]);

%All court members must ride unless there is no horse left available
constraint sum([horse[x] > 0 | x in COURT]) = max_riding;

%If a court member holds a higher rank than another, then either 
constraint forall(i, j in COURT where rank[i] > rank[j])( (beauty[horse[i]] >= beauty[horse[j]]) \/ %(a) the beauty of their horse can be no less than that assigned to the other
                                                           horse[j] = 0 \/                          %(b) the lower rank member does not ride, or
                                                          (horse[i] = 0 /\ horse[j] = 0));          %(c) both court members do not ride.

%If a horse is faster than another then either
var int: violation_cost;
violation_cost = sum(i, j in HORSE where speed[i] > speed[j])
                                                            (bool2int(not(
                                                                            ability[court[i]] >= ability[court[j]]  \/ %(a) the rider of the faster horse has no less riding
                                                                                                                       %    ability than that of the slower horse
                                                                            court[i] = 0 \/                            %(b) the faster horse has no rider
                                                                            (court[i] = 0 /\ court[j] = 0)             %(c) both horses have no rider
                                                                          )
                                                                      )
                                                             )*100; 

%Channeling
constraint forall(c in COURT, h in HORSE)(horse[c] = h <-> court[h] = c);

var int: obj;
constraint obj = sum(i in COURT where horse[i] > 0)(enjoy[i, horse[i]]) - violation_cost;

solve maximize obj;

output ["horse = \(horse);\nobj = \(obj);"];
