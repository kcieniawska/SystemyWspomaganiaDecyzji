include "globals.mzn";


int: items_n;
int: knapsacks_n;
int: capacity;
array[1..items_n] of int: values;
array[1..items_n] of int: weights;


array[1..knapsacks_n, 1..items_n] of var 0..1: taken;

constraint forall(j in 1..items_n) (
    sum(i in 1..knapsacks_n)(taken[i, j]) <= 1
);


constraint forall(i in 1..knapsacks_n) (
    sum(j in 1..items_n)(taken[i, j] * weights[j]) <= capacity
);


constraint forall(i in 1..knapsacks_n-1) (
    lex_less(row(taken, i), row(taken, i+1))
);


var int: total_value = sum(i in 1..knapsacks_n, j in 1..items_n) (
    taken[i, j] * values[j]
);

solve maximize total_value;

output [
    "Całkowita wartość: ", show(total_value), "\n",
    "Rozkład w plecakach:\n"
] ++ [
    "Plecak \(i): " ++ show([j | j in 1..items_n where fix(taken[i, j]) == 1]) ++ "\n"
    | i in 1..knapsacks_n
];