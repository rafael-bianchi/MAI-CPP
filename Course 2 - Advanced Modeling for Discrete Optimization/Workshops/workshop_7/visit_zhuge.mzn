enum PERSON; % set of people to be visited

array[PERSON] of int: duration;    % duration of visit
array[PERSON] of bool: on_weekend; % can the person be visited over weekends
array[PERSON] of int: rank;        % rank of person

array[int,1..2] of PERSON: prec;   % precedences between visits
set of int: PREC = index_set_1of2(prec); 

0..6: starting_day; % which day of the week is day 0 in the schedule
                    % 0 Monday, 1 Tuesday, ..., 5 Saturday, 6 Sunday

% upper bound on the amount of time needed: total duration plus 1 week
% per person who cant be visited on the weekend
int: total = sum(duration) + 7*sum(p in PERSON)(on_weekend[p] = false);
set of int: TIME = 0..total;

array[PERSON] of var TIME: start;
var TIME: end;

constraint forall(p in PREC)
                 (start[prec[p,1]] + duration[prec[p,1]] <=
                  start[prec[p,2]]);

constraint forall(p in PERSON)(start[p] + duration[p] <= end);

include "disjunctive.mzn";
constraint disjunctive(start, duration);

array[int] of TIME: weekend_start = 
                    [ t | t in TIME
                      where (starting_day + t) mod 7 = 5];

array[1..length(weekend_start)] of int: weekend_dur = 
           [2 | i in 1..length(weekend_start)];

array[int] of var TIME: notweekend_start
          = [ start[p] | p in PERSON where on_weekend[p] = false ];
          
array[int] of int: notweekend_dur
          = [ duration[p] | p in PERSON where on_weekend[p] = false ];

constraint disjunctive(weekend_start ++ notweekend_start,
                       weekend_dur ++ notweekend_dur);

var int: rank_violation;
constraint rank_violation = sum(p1, p2 in PERSON
                                 where rank[p1] > rank[p2])
                                 (start[p1] < start[p2]);

solve minimize card(PERSON)*card(PERSON)*end + rank_violation;

