% Dostępne kolory
kolor(czerwony).
kolor(zielony).
kolor(niebieski).

% Predykat pomocniczy sprawdzający, czy sąsiedzi mają różne kolory
rozne(X, Y) :- X \= Y.

% Główny predykat koloruj(A, B, C, D, E)
koloruj(A, B, C, D, E) :-
    % Przypisanie dostępnych kolorów dla każdego państwa
    kolor(A), kolor(B), kolor(C), kolor(D), kolor(E),
    
    % Definicja więzów (sąsiedztwa na mapie)
    rozne(A, B),
    rozne(A, C),
    rozne(A, D),
    rozne(B, C),
    rozne(B, E),
    rozne(C, D),
    rozne(C, E),
    rozne(D, E).