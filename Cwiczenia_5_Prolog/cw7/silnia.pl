% Warunek bazowy: silnia z 0 to 1
silnia(0, 1).

% Krok rekurencyjny: dla N > 0
silnia(N, Wynik) :-
    N > 0,
    N1 is N - 1,          % Zmniejszamy problem o 1
    silnia(N1, Wynik1),   % Wywołanie rekurencyjne obliczające (N-1)!
    Wynik is N * Wynik1.  % Obliczenie ostatecznego wyniku: N * (N-1)!