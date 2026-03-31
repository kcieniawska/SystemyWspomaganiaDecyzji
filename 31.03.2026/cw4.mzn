include "count.mzn";


int: n = 4; 


array[0..n-1] of var 0..n: s;


constraint forall(i in 0..n-1) (
    s[i] = count(s, i)
);


constraint sum(s) = n;


constraint sum(i in 0..n-1) (s[i] * i) = n;

solve satisfy;

output ["Magiczna seria (n=\(n)): \(s)\n"];