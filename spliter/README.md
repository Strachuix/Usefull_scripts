## Spliter

Prosty skrypt Bash (`spliter.sh`), który dzieli plik `table.sql` na mniejsze fragmenty. Skupia się na liniach zaczynających się od `INSERT`, pobiera co dziesiątą z nich (oraz ostatnią), a następnie używa ich jako granic do przygotowania plików `fragment_*.sql`.

### Jak to działa
- `grep` zapisuje numery wszystkich linii rozpoczynających się od `INSERT` do `linie_all.txt`.
- `awk` zostawia co dziesiątą linię oraz ostatnią — wynik trafia do `linie.txt`.
- Do listy dodawana jest jeszcze liczba wszystkich linii z `table.sql`, by mieć końcową granicę.
- Pętla `for` przechodzi po parach kolejnych numerów i każdą z nich traktuje jako zakres do wycięcia (`sed -n "start,endp"`).
- Każdy zakres trafia do osobnego pliku `fragment_X.sql`, a w terminalu pojawia się komunikat z numerami linii.

### Uruchomienie w Git Bash (Windows)
1. Otwórz Git Bash w folderze `spliter`.
2. Upewnij się, że `table.sql` zawiera dane do podziału (domyślna nazwa w skrypcie to `INPUT="table.sql"`).
3. Nadaj prawa wykonywalne (jednorazowo):
	```bash
	chmod +x spliter.sh
	```
4. Uruchom skrypt:
	```bash
	./spliter.sh
	```
	(alternatywnie `bash spliter.sh`).

### Wynik
- W katalogu pojawią się pliki `linie_all.txt`, `linie.txt` oraz `fragment_1.sql`, `fragment_2.sql`, ...
- Każdy `fragment_X.sql` zawiera zakres linii od kolejnego wykrytego `INSERT` do poprzedzającej go granicy, dzięki czemu łatwiej załadować mniejsze porcje danych.
