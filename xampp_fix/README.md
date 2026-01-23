# XAMPP MySQL Fix

## Opis
Skrypt naprawczy dla MySQL w XAMPP, który przywraca działanie serwera MySQL poprzez odbudowę struktury danych z wykorzystaniem kopii zapasowej (backup).

## Przeznaczenie
Ten skrypt jest używany, gdy MySQL w XAMPP:
- Nie chce się uruchomić
- Zawiesza się przy starcie
- Ma uszkodzone pliki systemowe
- Wyświetla błędy związane z plikami bazy danych

## Jak działa
Skrypt wykonuje następujące operacje:
1. **Zatrzymuje proces MySQL** - zamyka wszystkie działające procesy `mysqld.exe`
2. **Tworzy kopię zapasową** - obecny folder `data` zostaje przemianowany na `data_old`
3. **Tworzy nową strukturę** - kopiuje zawartość z folderu `backup` do nowego folderu `data`
4. **Przywraca bazy użytkownika** - kopiuje wszystkie niestandardowe bazy danych z `data_old` (pomija systemowe: mysql, performance_schema, phpmyadmin, test)
5. **Przywraca plik ibdata1** - kopiuje kluczowy plik InnoDB z poprzedniej instalacji

## Wymagania
- XAMPP zainstalowany w lokalizacji `C:\xampp`
- Istniejący folder backup: `C:\xampp\mysql\backup`
- Uruchomienie z uprawnieniami administratora

## Użycie
1. **Zatrzymaj XAMPP** - upewnij się, że Apache i MySQL są zatrzymane
2. **Uruchom skrypt** - kliknij prawym przyciskiem na `fix.bat` i wybierz "Uruchom jako administrator"
3. **Poczekaj na zakończenie** - skrypt wykona wszystkie operacje automatycznie
4. **Uruchom MySQL** - otwórz XAMPP Control Panel i uruchom MySQL

```batch
fix.bat
```

## Konfiguracja
Jeśli XAMPP jest zainstalowany w innej lokalizacji, edytuj linię 3 w skrypcie:
```batch
set XAMPP_PATH=C:\xampp
```

## Ostrzeżenia
⚠️ **UWAGA:** 
- Zawsze wykonuj backup swoich baz danych przed uruchomieniem skryptu
- Stary folder `data` zostanie przemianowany na `data_old`, ale wcześniejszy `data_old` zostanie usunięty
- Skrypt zakłada, że folder `backup` zawiera czyste, działające pliki systemowe MySQL

## Co robi z bazami danych
- ✅ **Zachowuje:** Wszystkie niestandardowe bazy danych
- ❌ **Odświeża:** Systemowe bazy MySQL (mysql, performance_schema, phpmyadmin, test)
- ✅ **Zachowuje:** Plik ibdata1 (tabele InnoDB)

## Troubleshooting
- **MySQL nadal nie działa** - sprawdź logi w `C:\xampp\mysql\data\*.err`
- **Brak foldera backup** - skopiuj folder `backup` z czystej instalacji XAMPP
- **Błąd uprawnień** - uruchom skrypt jako administrator
- **Brakuje baz danych** - sprawdź folder `data_old` i skopiuj ręcznie potrzebne bazy

## Autor
Skrypt narzędziowy do szybkiej naprawy XAMPP MySQL

## Licencja
Darmowy do użytku osobistego i komercyjnego
