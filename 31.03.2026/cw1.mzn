
int: n = 8;


array[1..n] of var 1..n: queens;


include "alldifferent.mzn";
constraint alldifferent(queens);


constraint alldifferent([queens[i] + i | i in 1..n]); % Przekątna "/"
constraint alldifferent([queens[i] - i | i in 1..n]); % Przekątna "\"


solve satisfy;


output [
    if fix(queens[i]) == j then "Q " else ". " endif ++
    if j == n then "\n" else "" endif
    | i, j in 1..n
];