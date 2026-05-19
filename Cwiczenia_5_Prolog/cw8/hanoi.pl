% Warunek brzegowy: przeniesienie 1 dysku to po prostu wypisanie ruchu
move(1, Skad, Dokad, _) :-
    write('Przenies dysk 1 z poziomu '), write(Skad), write(' na '), write(Dokad), nl.

% Krok rekurencyjny dla N dysków:
move(N, Skad, Dokad, Pomocniczy) :-
    N > 1,
    M is N - 1,
    move(M, Skad, Pomocniczy, Dokad), % 1. Przenieś N-1 dysków na słupek pomocniczy
    write('Przenies dysk '), write(N), write(' z poziomu '), write(Skad), write(' na '), write(Dokad), nl, % 2. Przenieś największy dysk na docelowy
    move(M, Pomocniczy, Dokad, Skad). % 3. Przenieś N-1 dysków z pomocniczego na docelowy