% --- Dane  ---
int: cel = 1505;

% Posilki
enum Posilki = { Owoce, Frytki, Salatka, Skrzydelka, Paluszki, Zestaw_probny };

% Tablica cen przypisana do posilkow
array[Posilki] of int: ceny = [215, 275, 335, 355, 420, 580];

% --- Zmienne  ---
array[Posilki] of var int: ile_sztuk;

% Kazda ilosc musi byc wieksza lub rowna 0
constraint forall(p in Posilki) (
    ile_sztuk[p] >= 0
);

% Suma iloczynow cena * ilosc musi dac cel
constraint sum(p in Posilki) (
    ile_sztuk[p] * ceny[p]
) = cel;

% --- Rozwiązanie ---
solve satisfy;

% --- Wynik ---
output [
    "Zamowienie dla sumy \(cel):\n"
] ++ [
    "\(p): \(ile_sztuk[p]) szt.\n" 
    | p in Posilki where fix(ile_sztuk[p]) > 0
];