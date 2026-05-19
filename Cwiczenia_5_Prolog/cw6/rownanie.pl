% Delta/4: Oblicza deltę dla współczynników A, B, C i przypisuje wynik do D
delta(A, B, C, D) :-
    D is (B ** 2) - (4 * A * C).

% kwadrat/4: Główny predykat przyjmujący A, B, C i zwracający rozwiązania w postaci listy [X1, X2] lub [X0]

% Przypadek 1: Delta dodatnia (dwa rozwiązania)
kwadrat(A, B, C, [X1, X2]) :-
    delta(A, B, C, D),
    D > 0,
    X1 is (-B - sqrt(D)) / (2 * A),
    X2 is (-B + sqrt(D)) / (2 * A).

% Przypadek 2: Delta równa zero (jedno rozwiązanie)
kwadrat(A, B, C, [X0]) :-
    delta(A, B, C, D),
    D =:= 0,  % =:= oznacza równość arytmetyczną w Prologu
    X0 is -B / (2 * A).

% Przypadek 3: Delta ujemna (brak rozwiązań rzeczywistych)
kwadrat(A, B, C, []) :-
    delta(A, B, C, D),
    D < 0,
    write('Brak rozwiazan w zbiorze liczb rzeczywistych!'), nl.