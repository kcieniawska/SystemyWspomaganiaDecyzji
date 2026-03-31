include "alldifferent.mzn";

array[1..9, 1..9] of int: board = [|
  5, 3, 0, 0, 7, 0, 0, 0, 0 |
  6, 0, 0, 1, 9, 5, 0, 0, 0 |
  0, 9, 8, 0, 0, 0, 0, 6, 0 |
  8, 0, 0, 0, 6, 0, 0, 0, 3 |
  4, 0, 0, 8, 0, 3, 0, 0, 1 |
  7, 0, 0, 0, 2, 0, 0, 0, 6 |
  0, 6, 0, 0, 0, 0, 2, 8, 0 |
  0, 0, 0, 4, 1, 9, 0, 0, 5 |
  0, 0, 0, 0, 8, 0, 0, 7, 9 |];


array[1..9, 1..9] of var 1..9: puzzle;


constraint forall(i, j in 1..9) (
    if board[i,j] > 0 then puzzle[i,j] = board[i,j] else true endif
);


constraint forall(i in 1..9) (
    alldifferent([puzzle[i,j] | j in 1..9])
);


constraint forall(j in 1..9) (
    alldifferent([puzzle[i,j] | i in 1..9])
);


constraint forall(r, c in 0..2) (
    alldifferent([puzzle[r*3 + i, c*3 + j] | i, j in 1..3])
);


solve satisfy;


output [
    show(puzzle[i,j]) ++ (if j == 9 then "\n" else " " endif)
    | i, j in 1..9
];