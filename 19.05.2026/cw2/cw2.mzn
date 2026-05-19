
include "diffn.mzn";
include "cumulative.mzn";

int: n;

array[1..n] of int: sizes = [i | i in 1..n];

int: max_dim = sum(sizes);


array[1..n] of var 0..max_dim: x;
array[1..n] of var 0..max_dim: y;

var 1..max_dim: width;
var 1..max_dim: height;
var 1..max_dim * max_dim: area = width * height;


constraint forall(i in 1..n)(x[i] + sizes[i] <= width);
constraint forall(i in 1..n)(y[i] + sizes[i] <= height);

constraint diffn(x, y, sizes, sizes);

constraint cumulative(x, sizes, sizes, height);
constraint cumulative(y, sizes, sizes, width);
constraint not (
    (x[n] < x[n-1] + sizes[n-1] /\ x[n-1] < x[n] + sizes[n]) /\
    (y[n] + sizes[n] == y[n-1] \/ y[n-1] + sizes[n-1] == y[n])
);

constraint x[1] > 0 /\ x[1] + 1 < width;
constraint y[1] > 0 /\ y[1] + 1 < height;


solve minimize area;


output [
  "Kontener: ", show(width), " x ", show(height), " (Pole: ", show(area), ")\n",
  "Pozycje kwadratów (x, y):\n"
] ++ 
[ "Kwadrat " ++ show(i) ++ "x" ++ show(i) ++ ": (" ++ show(x[i]) ++ ", " ++ show(y[i]) ++ ")\n" | i in 1..n ];