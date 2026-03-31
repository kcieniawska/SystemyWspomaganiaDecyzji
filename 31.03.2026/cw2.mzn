
int: n = 4;


set of int: Nodes = 1..n;
array[1..n, 1..n] of bool: adj = array2d(Nodes, Nodes, [
    i != j | i, j in Nodes
]);


array[Nodes] of var 1..n: color;


var 1..n: num_colors;


constraint forall(i, j in Nodes where adj[i,j]) (
    color[i] != color[j]
);


constraint forall(i in Nodes) (
    num_colors >= color[i]
);


solve minimize num_colors;


output ["Liczba kolorów: \(num_colors)\n"] ++
       ["Wierzchołek \(i): kolor \(color[i])\n" | i in Nodes];