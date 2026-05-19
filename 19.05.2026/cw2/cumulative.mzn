predicate cumulative(array[int] of var int: s,  
                     array[int] of int: d,      
                     array[int] of int: r,      
                     int: b) =                  
   forall(t in min(s)..max(s) + max(d)) (
       sum(i in index_set(s)) (
           bool2int(s[i] <= t /\ t < s[i] + d[i]) * r[i]
       ) <= b
   );