% Warunki bazowe
fib(0, 0).
fib(1, 1).

% Krok rekurencyjny dla N > 1
fib(N, Wynik) :-
    N > 1,
    N1 is N - 1,
    N2 is N - 2,
    fib(N1, Wynik1), % Wyznaczenie wartości pierwszego sąsiada wstecz
    fib(N2, Wynik2), % Wyznaczenie wartości drugiego sąsiada wstecz
    Wynik is Wynik1 + Wynik2.