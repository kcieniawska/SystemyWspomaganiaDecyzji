% Ceny posiłków
int: owoce = 215;
int: frytki = 275;
int: salatka = 335;
int: skrzydelka = 355;
int: paluszki = 420;
int: zestaw_probny = 580;

% Ile sztuk każdego posiłku bierzemy
var int: n_owoce;
var int: n_frytki;
var int: n_salatka;
var int: n_skrzydelka;
var int: n_paluszki;
var int: n_zestaw;

% Liczby muszą być nieujemne
constraint n_owoce >= 0;
constraint n_frytki >= 0;
constraint n_salatka >= 0;
constraint n_skrzydelka >= 0;
constraint n_paluszki >= 0;
constraint n_zestaw >= 0;

% Główne równanie kosztu
constraint 
  n_owoce * owoce + 
  n_frytki * frytki + 
  n_salatka * salatka + 
  n_skrzydelka * skrzydelka + 
  n_paluszki * paluszki + 
  n_zestaw * zestaw_probny = 1505;

solve satisfy;

% Wyniki
output [
  "Owoce: \(n_owoce), ",
  "Frytki: \(n_frytki), ",
  "Sałatka: \(n_salatka), ",
  "Skrzydełka: \(n_skrzydelka), ",
  "Paluszki: \(n_paluszki), ",
  "Zestaw próbny: \(n_zestaw)\n"
];