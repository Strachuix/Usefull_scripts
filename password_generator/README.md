# Generator Haseł JX

## Opis

Generator haseł JX to skrypt bash, który automatycznie generuje silne, bezpieczne hasła spełniające wymagania bezpieczeństwa. Każde wygenerowane hasło:

- Zaczyna się prefiksem `JX` (2 znaki)
- Ma łącznie 12 znaków
- Zawiera przynajmniej jedną małą literę
- Zawiera przynajmniej jedną wielką literę
- Zawiera przynajmniej jedną cyfrę
- Zawiera przynajmniej jeden znak specjalny (!@#$%)

## Funkcjonalność

- **Kryptograficznie bezpieczne**: Używa `/dev/urandom` do generowania losowych znaków
- **Elastyczna ilość**: Pozwala na wygenerowanie dowolnej liczby haseł
- **Automatyczne dostosowanie długości**: Suffix automatycznie dostosowuje się do długości prefixu, aby utrzymać 12 znaków łącznie
- **Automatyczne zapisywanie**: Wyniki są automatycznie zapisywane na pulpicie
- **Inteligentne nazewnictwo plików**: Jeśli plik już istnieje, skrypt automatycznie tworzy `hasla_1.txt`, `hasla_2.txt` itd.
- **Walidacja danych**: Sprawdza, czy użytkownik podał prawidłową liczbę

## Wymagania

- System Linux/Unix/macOS z interpreterem bash
- Dostęp do `/dev/urandom`
- Uprawnienia do zapisu na pulpicie

## Jak uruchomić

### 1. Nadaj uprawnienia do wykonania
```bash
chmod +x passgen.sh
```

### 2. Uruchom skrypt
```bash
./passgen.sh
```

### 3. Podaj ilość haseł
Skrypt zapyta się, ile haseł chcesz wygenerować. Wpisz liczbę i naciśnij Enter.

### Przykład wykonania
```
============================================
      GENERATOR HASEŁ JX (12 ZNAKÓW)     
============================================
Ile haseł wygenerować? 5

Generowanie haseł...
Hasło 1: JXA9!mKpB2x
Hasło 2: JXB2@xQwC5y
Hasło 3: JXC5#yReD7z
Hasło 4: JXD7$zTyE1a
Hasło 5: JXE1!aUiF3b

--------------------------------------------
Gotowe! Hasła zapisano w: /home/user/Desktop/hasla.txt
```

## Gdzie znajdują się hasła?

Wygenerowane hasła są automatycznie zapisywane na pulpicie:
- `hasla.txt` - jeśli pliku nie było
- `hasla_1.txt`, `hasla_2.txt` itd. - jeśli plik już istnieje

## Zawartość pliku z hasłami

Plik zawiera:
- Datę i czas generowania
- Separatory
- Listę wszystkich wygenerowanych haseł

## Bezpieczeństwo

Skrypt używa `LC_ALL=C tr -dc` z `/dev/urandom`, co zapewnia kryptograficznie bezpieczne generowanie liczb losowych, znacznie lepsze niż zwykły `$RANDOM`.

## Ograniczenia

- **Minimalny suffix**: 4 znaki (zapewnia wystarczającą losowość)
- Jeśli prefiks jest dłuższy niż 8 znaków, suffix automatycznie będzie mieć dokładnie 4 znaki
- Całkowita długość hasła może być większa niż 12 znaków w przypadku dłuższego prefixu

## Przykłady

Jeśli chcesz zmienić prefiks, edytuj linię 3 w skrypcie:
```bash
PREFIX="JX"
```
**Ważne**: Długość suffixu dostosuje się automatycznie! Nie musisz nic więcej zmieniać.

Jeśli chcesz zmienić docelową długość hasła (domyślnie 12), edytuj:
```bash
TARGET_LENGTH=12
```

Jeśli chcesz dodać inne znaki specjalne, edytuj linię 5:
```bash
CHARS="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%&"
```
