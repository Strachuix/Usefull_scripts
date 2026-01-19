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

---

# Wysyłanie maili z załącznikami (send_emails.sh)

Skrypt `send_emails.sh` automatycznie wysyła zaszyfrowane pliki ZIP na adresy email z pliku `emails.txt`.

## Jak to działa

1. **Czyta maile** z pliku `emails.txt`
2. **Wyodrębnij nazwę użytkownika** (część przed `@`)
3. **Sprawdza** czy istnieje plik ZIP o pasującej nazwie w folderze `pass_zips`
4. **Wysyła email** z załącznikiem ZIP (jeśli plik istnieje)
5. **Pomija** emaile bez odpowiadającego pliku ZIP

## Konfiguracja

### 1. Edytuj plik `smtp_config.txt`

```bash
FROM_EMAIL="example@email.pl"
FROM_PASSWORD="password"    # ⚠️ Zmień na swoje hasło
SMTP_SERVER="smtp.example.com"
SMTP_PORT="587"
```

### 2. Edytuj plik `emails.txt`

Lista maili, na które mają być wysłane wiadomości (jeden email per linię):

```
example@email.com
user@ex.pl
```

### 3. Tekst wiadomości

Edytuj zmienną `BODY` na górze pliku `send_emails.sh`:

```bash
BODY="Customowa wiadomość"
```

## Uruchomienie

```bash
chmod +x send_emails.sh
./send_emails.sh
```

## Warunki wysłania

Email **zostanie wysłany TYLKO jeśli**:
- Email znajduje się w pliku `emails.txt`
- Istnieje plik ZIP: `pass_zips/NAZWA_UZYTKOWNIKA.zip`
- NAZWA_UZYTKOWNIKA = część emaila przed `@`

**Przykład:**
- Email: `example@email.pl` → szuka pliku `pass_zips/example.zip`
- Email: `user@ex.pl` → szuka pliku `pass_zips/user.zip`

Jeśli plik ZIP nie istnieje, email jest **pomijany** (zostaje wyświetlone ostrzeżenie).

## Wymagania

- `curl` - do wysyłania maili via SMTP
- Dostęp do SMTP serwera z włączonym logowaniem
