% {arametry
int: budzet;
enum Posilki;
array[Posilki] of int: ceny;

% Ile sztuk każdego posiłku kupujemy
array[Posilki] of var int: ile_sztuk;


% 1. Liczba sztuk musi być nieujemna
constraint forall(p in Posilki) (
    ile_sztuk[p] >= 0
);

% 2. Suma kosztów musi być dokładnie równa budżetowi
constraint sum(p in Posilki) (
    ile_sztuk[p] * ceny[p]
) = budzet;

% Rozwiązanie
solve satisfy;

% Czytelny wynik
output [
    "Budzet do wykorzystania: \(budzet)\n",
    "----------------------------\n"
] ++ [
    "\(p): \(ile_sztuk[p]) szt. (\(ile_sztuk[p] * ceny[p]))\n" 
    | p in Posilki where fix(ile_sztuk[p]) > 0
];