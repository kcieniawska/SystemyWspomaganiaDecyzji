% Dane
int: budzet = 1505;

enum Posilki = { Owoce, Frytki, Salatka, Skrzydelka, Paluszki, Zestaw_probny };

array[Posilki] of int: ceny = [215, 275, 335, 355, 420, 580];

% yumyum factor
array[Posilki] of int: yumyum = [0, 0, 1, 1, 2, 3];

% Zmienne
array[Posilki] of var int: ile_sztuk;

% Ograniczenia
constraint forall(p in Posilki) (
    ile_sztuk[p] >= 0
);

% Suma kosztów musi być DOKŁADNIE równa 1505

constraint sum(p in Posilki) (
    ile_sztuk[p] * ceny[p]
) = budzet;

% Obliczamy całkowity smak jako sumę (ilość * yumyum factor)
var int: calkowity_smak = sum(p in Posilki) (
    ile_sztuk[p] * yumyum[p]
);

% Zamiast 'solve satisfy', używamy 'solve maximize'
solve maximize calkowity_smak;

% --- Wynik ---
output [
  "Maksymalny smak: \(calkowity_smak)\n",
  "----------------------------\n"
] ++ [
  "\(p): \(ile_sztuk[p]) szt. (Smak: \(ile_sztuk[p] * yumyum[p]))\n" 
  | p in Posilki where fix(ile_sztuk[p]) > 0
];