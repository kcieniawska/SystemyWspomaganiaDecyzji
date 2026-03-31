% Use this editor as a MiniZinc scratch book
int: N; %rozmiar szachownicy
array[1..N] of var 1..N: rows; %rows[i] numer wiersa w którym stoi hetman w kolumnie i
% np. rows = [4, 2, 7, ...] w kolumnie 1 hetman w wierszu 4, w kolumnie 2 hetman w wierszy 2, itd
include "alldifferent.mzn";
constraint
% żadnych dwóch hetmanów nie może być w tej samej kolumnie
%alldifferent(rows) - żaden wiersz się nie powtarza
% żadnych dwóch hetmanów nie może być na tej samej przekątnej do góry
% żadnych dwóch hetmanów nie może być na tej samej przekątnej do dołu
% rows[i] + i to numer przekątnej w kierunku z lewej górnej do prawej dolnej
% rows[i] - i to numer przekątnej w kierunku z prawej górnej do lewej dolnej 

solve satisfy;

[if j=rows[i] then "H" else "." endif ++ 
 if j=N then "\n" else " " endif | i in 1..N, j in 1..N];
 
 
 %%%%%%%%%%%%%%%%%%%%%
 %kolorowanie wierzchołków grafu
 int: nodesNumber;
 array[1..nodesNumber, 1..nodesNumber] of bool: edges;
 int: n=5 %liczba wierzchołków
 int: m=6; %liczba krawędzi;
 int: k=3; %liczba dostępnych kolorów
 array[1..m, 1..2] of int: edges = 
 [
   | 1, 2
   | 1, 5
   | 2, 3
   | 3, 4
   | 4, 5
   | 5, 3
 ];
 
 var 1..nodesNumber: colorsNumber = max(nodes);
 array[1..nodesNumber] of var 1..nodesNumber: nodes;
 constraint
 %dla każdej pary wierzchołków i, j jeżeli istnieje między nimi krawędź to nodes[i] != nodes[j]
solve minimize colorsNumber;
output [show(colorsNumber), " colors \n"]
[show(nodes[i]) ++ " " | i in 1..nodesNumber]

%%%%%%%%%%%%%%%%%%%%%
%Sudoku
%stwórz kod który pozwala albo znaleźć wszystkie kombinacje dla pustej planszy
%albo wczyta planszę z podanymi startowymi liczbami bo tak zwykle wyglądają zagadki sudoku
include "alldifferent.mzn";
int: S = 3;   %rozmiar małego kwadratu
int: N = S * S; % rozmiar dużego kwadratu (planszy 9 x 9)
set of int: PuzzleRange = 1..N; % zakres indeksów planszy od 1 do 9
set of int: SingleSquareRange = 1..S; %zakres indeksów mniejszych kwadratów od 1 do 3
array[PuzzleRange, PuzzleRange] of 0..N: board; %% initial board = 0 empty ale może nie być pusta, w zadaniach część liczb jest podana
%np.
array[1..9, 1..9] of 0..9: board = 
[
   |5,3,0,0,7,0,0,0,0
   |6,0,0,1,9,5,0,0,0
   |0,9,8,0,0,0,0,6,0
   |8,0,0,0,6,0,0,0,3
   |4,0,0,8,0,3,0,0,1
   |7,0,0,0,2,0,0,0,6
   |0,6,0,0,0,0,2,8,0
   |0,0,0,4,1,9,0,0,5
   |0,0,0,0,8,0,0,7,9
];
array[PuzzleRange, PuzzleRange] of var PuzzleRange: puzzle;  %to plansza w której MiniZinc dopisze brakujące liczby
constraint
%dla dowolnego r, c z PuzzleRange, jeżeli board[r,c]>0 to puzzle[r,c]=board[r,c] - przepisanie wartości z planszy wejściowej
% do planszy gdzie MiniZinc szuka rozwiązań
%różne wartości w wierszach 
%różne wartosci w kolumnach
%różne wartości w 3x3 - minikwadratach

solve satisfy;
output [show(puzzle[i,j]) ++
if i mod S == 0 then " " else "" endif ++
if i ==N /\ i !=N then 
if i mod S == 0 then "\n\n" else "\n" endif else "" endif | 
i,j in PuzzleRange ] ++ ["\n"];

 
%dwie tablice nie są konieczne, ale często się tak robi, żeby widać było wejście i wyjście

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Magiczny kwadrat
% taki układ że suma wierszy, kolumn, przekątnych jest zawsze taka sama i liczby się nie powtarzają 
% (ok, to pierwsze to bardziej magic square)
%magic_sum = n*(n*n+1)/2
%reszta podobnie jak w Sudoku
%np. 8 1 6
%    3 5 7
%    4 9 2
int:n = 3;
int: n2 = n*n;
array[1..n, 1..n] of var 1..n2: square;
int: magic_sum %warunek już wyżej napisany jak obliczać
% wszystkie liczby mają się pojawić dokładnie raz, użyj aldeifferent
constraint
%suma wierszy = magic_sum;
constraint
%suma kolumn = magic_sum;
constraint
%suma przekątkich = magic_sum;
solve satisfy;

output [
   if j=1 then "]n" else "" endif ++
   show(square[i,j]) ++
   if j=n then "\n" else " " endif 
   | i, j in 1..n
];
%czyli generujemy pary (i,j) czyli wszpółrzędne wiersza i kloumny
%np. square[1,1], sqare[1,2] itd
%jeżeli zaczynamy nowy wiersz to j=1 i wtedy wstaw znak nowej linii
%show(square[i,j]) zamieniami wartość zmiennej square[i,j] na tekst do wypisania
% if j=n then "\n| e;se " " end if
%czyli jeżeli jesteśmy na końcu wiersza to j=n
%i wtedy dodajemy nową linię po ostatnim numerze w wierszu4% 4
%jeżeli nie to dodajemy zwykłą spację żeby rozdzielić liczby

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Magiczna seria
% Taki ciąg, że (najlepiej przykład): magic[1,2,1,0]
% magic[1] = 1 bo liczba 0 występuje jeden raz
% magic[2] = 2 bo liczba 1 występuje 2 razy
% magic[3] = 1 bo liczba 2 występuje 1 raz
% magic[4] = 0 bo liczba 3 występuje 0 razy
%proszę stworzyć kod dla obydwu interpretacji, zarówno sumy liczb jak i magicznej serii w rozumieniu drugim

%warto sobie to zapisać najpierw w pseudokodzie a potem w MiniZincu

int: len = 5;
array[1..len] of var 0..len: magic;
constraint
%forall (i in 1..len) (...) sprawdzamy coś dla każdej pozycji w tablicy magic
%magic[i]= (...) - liczba w pozycji i mówi ile razy liczba i-1 występuje w całej tablicy (liczby od zera czyli i-1
%sum(j in 1..len)(bool2int (magic[j]=i-1)) liczymy ile razy wartość i-1 występuje w tablicy
%bool2int zamienia wynik na liczbę albo true w 1 albo false w 0



