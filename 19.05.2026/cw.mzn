
int: n = 16;
array[1..n] of var 1..n: rows;

include "alldifferent.mzn";

constraint alldifferent(rows);
constraint alldifferent([rows[i] + i | i in 1..n]);
constraint alldifferent([rows[i] - i | i in 1..n]);
constraint sum(i in 1..n where i mod 2 == 1)(bool2int(rows[i] mod 2 == 1)) >= 2;
constraint sum(i in 1..n)(bool2int(rows[i] >= 4 /\ rows[i] <= 13)) >= 6;

solve satisfy;

output [show(rows)];