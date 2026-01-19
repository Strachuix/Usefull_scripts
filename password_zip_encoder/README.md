# Password ZIP Encoder

## Opis

Skrypt `generator.sh` automatycznie konwertuje listę haseł na zaszyfrowane pliki ZIP. Każde hasło zostaje umieszczone w osobnym pliku tekstowym, a następnie zaarchiwizowane za pomocą silnego szyfrowania AES-256.

## Jak to działa

1. **Odczytanie danych wejściowych**: Skrypt czyta plik `lista.txt` zawierający pary danych (hasło i nazwa użytkownika)
2. **Tworzenie pliku tymczasowego**: Dla każdego wiersza tworzy plik `.txt` zawierający hasło
3. **Szyfrowanie ZIP**: Archiwizuje plik tekstowy do formatu ZIP z hasłem ochronnym (AES-256)
4. **Czyszczenie**: Usuwa plik tymczasowy `.txt`, pozostawiając tylko zabezpieczony archiwum

## Konfiguracja

Przed uruchomieniem skryptu edytuj następujące zmienne na początku pliku:

```bash
INPUT_FILE="lista.txt"      # Nazwa pliku ze źródłowymi danymi
ZIP_PASSWORD="TwojeHaslo"   # Hasło chroniące wszystkie pliki ZIP
OUTPUT_DIR="pass_zips"      # Folder, gdzie będą tworzone pliki ZIP
```

Folder `pass_zips` **zostanie automatycznie utworzony**, jeśli nie istnieje.

## Format pliku wejściowego

Plik `lista.txt` powinien zawierać dwie kolumny oddzielone spacją:

```
hasło_email nazwa_użytkownika
hasło_email2 nazwa_użytkownika2
```

**Przykład:**
```
SecurePass123 user_john
MyPassword456 user_anna
```

## Wymagania

- **7-zip (7z)** - Program do kompresji i szyfrowania
  - Linux: `sudo apt install p7zip-full`
  - macOS: `brew install p7zip`
  - Windows: Pobranie z https://www.7-zip.org/

## Uruchomienie

```bash
chmod +x generator.sh
./generator.sh
```

Wymagany Bash i 7-zip (`sudo apt install p7zip-full`)

## Rezultat

Dla każdego wiersza z pliku `lista.txt` zostaną utworzone pliki ZIP w folderze `pass_zips`.

### Nazewnictwo plików

Pliki ZIP otrzymują nazwy bezpośrednio z drugiej kolumny pliku `lista.txt` (bez części mailowej):

```
pass_zips/nazwa_użytkownika.zip
```

**Przykład:**
- Z wiersza: `SecurePass123 user@email.pl` → `pass_zips/user.zip`
- Z wiersza: `MyPassword456 admin_robert` → `pass_zips/admin_robert.zip`

Każde archiwum zawiera jeden plik tekstowy z hasłem i jest chronione hasłem określonym w zmiennej `ZIP_PASSWORD`.

## Bezpieczeństwo

- Szyfrowanie: **AES-256** (wysokopoziomowe szyfrowanie)
- Wszystkie pliki tymczasowe są automatycznie usuwane
- Hasła są bezpiecznie przechowywane wewnątrz zaszyfrowanych plików ZIP

## Obsługa błędów

Skrypt sprawdza:
- Czy program 7z jest zainstalowany
- Czy plik `lista.txt` istnieje
- Pomija puste linie w pliku wejściowym
