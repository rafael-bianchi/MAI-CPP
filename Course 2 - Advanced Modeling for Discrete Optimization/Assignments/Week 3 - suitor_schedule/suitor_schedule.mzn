% scheduling suitors
enum SUITOR;
SUITOR: LiuBei; % which suitor is LiuBei
int: n; % number of meetings
set of int: MEETING = 1..n;
array[MEETING] of SUITOR: suitor;

enum ROOM = { Red, Gold, Blue };
array[SUITOR,ROOM] of int: mintime;
array[SUITOR,ROOM] of int: maxtime;
constraint forall(s in SUITOR, r in ROOM)
                 (assert(mintime[s,r] >= 1 /\ maxtime[s,r] >= mintime[s,r], 
                  "error in mintime/maxtime at [\(s),\(r)]\n"));

array[ROOM,ROOM] of int: move;
constraint forall(r in ROOM)(assert(move[r,r] = 0,"move[\(r),\(r)] != 0\n")); 

int: ndays; % number of days
set of int: DAY = 1..ndays;
int: earliest; % time for earliest meeting start
int: latest;  % time for end of latest meeting

int: lessontime; % time for kung fu lesson;
int: minsep;     % minimum time between consecutive kung fu lessons

array[ROOM] of int: usedstart;  % time others use each room each day
array[ROOM] of int: useddur;    % durations of others use

enum STAGE = {A,B,C};
STAGE: stage;

set of int: TIME = 0..24*ndays;

array[MEETING] of var TIME: start;
array[MEETING] of var TIME: dur;    % duration in false schedule
array[MEETING] of var ROOM: room;
set of int: KUNGFU = 1..n;
array[KUNGFU] of var int: kungfu;  % start time for each lesson
                                   % unused lessons have start times after 24*ndays

array[KUNGFU] of var 0..n: kfm;
array[MEETING] of var 0..1: consecutive;

% No overlapping
constraint forall(m1,m2 in MEETING where m1 < m2)
                 (start[m1] + dur[m1] + move[room[m1],room[m2]] <= start[m2]
                \/start[m2] + dur[m2] + move[room[m2],room[m1]] <= start[m1]);   

% check meetings consecutive order
constraint forall(s in SUITOR, m1, m2 in MEETING where suitor[m1] = s 
                 /\ suitor[m2] = s /\ m1 < m2)(start[m1] < start[m2]); 

% start earliest and latest ...
constraint forall(m in MEETING)((start[m] mod 24) >= earliest
                              /\(start[m] mod 24 + dur[m]) <= latest);

% meeting time greater than mintime, smaller than maxtime
constraint forall(m in MEETING)(dur[m] - consecutive[m] * lessontime >= mintime[suitor[m],room[m]]);
constraint forall(m in MEETING)(dur[m] <= maxtime[suitor[m],room[m]]);

% beginning + duration and end time.
constraint forall(m in MEETING)(start[m] mod 24 >= usedstart[room[m]] + useddur[room[m]] \/ start[m] mod 24 + dur[m] <= usedstart[room[m]]);
                                                     
% kungfu start time
constraint forall(k in KUNGFU) (kungfu[k] > 0 /\ kungfu[k] <= 24*ndays + n*(minsep+lessontime));  
constraint forall(k in 1..n-1)(kungfu[k] + lessontime + minsep <= kungfu[k+1]); 

constraint forall(m in MEETING)(stage != C -> consecutive[m] = 0);
constraint forall(k in KUNGFU)(stage != C -> kfm[k] = 0);

%constraint forall(k in KUNGFU) (kungfu[k] > 0 /\ kungfu[k] <= 24*ndays + n*(minsep+lessontime));  
%constraint forall(k in 1..n-1)(kungfu[k]); 
%
%constraint forall(m in MEETING)(stage != C -> consecutive[m] = 0);
%constraint forall(k in KUNGFU)(stage != C -> kfm[k] = 0);

constraint forall(k in KUNGFU  where (kungfu[k] <= 24*ndays) ) (
    if stage != C then true else
    exists(m in MEETING)(kungfu[k] + lessontime = start[m] + dur[m] /\ kfm[k] = m)
    endif);

constraint forall(m in MEETING)(
    if stage != C then true else
    if exists(k in KUNGFU)(kfm[k] = m) then consecutive[m] = 1 else consecutive[m] = 0 endif
    endif);  

% "Now you should include handling of the kung fu lessons" (kungfu only for C)
constraint forall(k in KUNGFU)(stage != C -> kungfu[k] > 24 * ndays);                                                                                                                 

% Objectives, according to stage
var int: obj_stages_A_and_B = sum(m in MEETING where suitor[m] = LiuBei)(dur[m]);
var int: liu_bei_meetings = sum(m in MEETING where suitor[m] = LiuBei)(dur[m] - consecutive[m]*lessontime);
var int: kungfu_classes = sum(k in KUNGFU)(if kungfu[k] <= 24 * ndays then 1 else 0 endif);
var int: obj_stage_C = 100 * kungfu_classes + liu_bei_meetings;

%var int: obj_stages_A_and_B = sum(m in MEETING where suitor[m] = LiuBei)(dur[m]);
%var int: liu_bei_meetings = sum(m in MEETING where suitor[m] = LiuBei)(dur[m] - consecutive[m]);
%var int: kungfu_classes = sum(k in KUNGFU)(kungfu[k] <= 24);
%var int: obj_stage_C = 50 * kungfu_classes + liu_bei_meetings;


var int: final_obj;
constraint if stage != C then final_obj = obj_stages_A_and_B else final_obj = obj_stage_C endif;

solve maximize final_obj;

output["start = \(start);\n"]++
      ["dur = \(dur);\n"]++
      ["room = \(room);\n"] ++
      ["kungfu = \(kungfu);\n"] ++ 
      ["obj = \(final_obj);"];
