include "globals.mzn";


int: N = 16; 

array[1..N] of var 1..N: rows;
array[1..N] of var 1..N: cols;
constraint inverse(rows, cols);

constraint alldifferent(rows);
constraint alldifferent([rows[i] + i | i in 1..N]);
constraint alldifferent([rows[i] - i | i in 1..N]);

constraint alldifferent(cols);
constraint alldifferent([cols[i] + i | i in 1..N]);
constraint alldifferent([cols[i] - i | i in 1..N]);

solve satisfy;
output [
  "N = \(N)\n",
  "Rows (Kolumna -> Wiersz): \(rows)\n",
  "Cols (Wiersz -> Kolumna): \(cols)\n"
];