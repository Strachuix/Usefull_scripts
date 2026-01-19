#!/bin/bash

# --- KONFIGURACJA ---
INPUT_FILE="lista.txt"      # Nazwa Twojego pliku wejściowego
ZIP_PASSWORD="jAr3x!"   # Hasło, którym będą zabezpieczone wszystkie ZIPy
OUTPUT_DIR="pass_zips"      # Folder, gdzie będą tworzone pliki ZIP
# --------------------

# Utwórz folder OUTPUT_DIR jeśli nie istnieje
if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR"
    echo "✓ Utworzono folder: $OUTPUT_DIR"
fi

# Znajdź 7z - spróbuj różnych ścieżek
find_7z() {
    # Najpierw spróbuj standardowego polecenia
    if command -v 7z &> /dev/null; then
        echo "7z"
        return 0
    fi
    
    # Na Windowsie spróbuj typowych ścieżek
    if [ -f "C:/Program Files/7-Zip/7z.exe" ]; then
        echo "C:/Program Files/7-Zip/7z.exe"
        return 0
    fi
    if [ -f "C:/Program Files (x86)/7-Zip/7z.exe" ]; then
        echo "C:/Program Files (x86)/7-Zip/7z.exe"
        return 0
    fi
    
    return 1
}

COMMAND_7Z=$(find_7z)

if [ -z "$COMMAND_7Z" ]; then
    echo "BŁĄD: Program 7z nie został znaleziony!"
    echo ""
    echo "Rozwiązania:"
    echo "1. Zainstaluj 7-Zip: https://www.7-zip.org/"
    echo "2. Lub edytuj zmienną COMMAND_7Z w tym pliku i podaj pełną ścieżkę do 7z.exe"
    echo ""
    echo "Przykład (dodaj na początku skryptu):"
    echo '   COMMAND_7Z="C:/Program Files/7-Zip/7z.exe"'
    exit 1
fi

# Sprawdź czy plik wejściowy istnieje
if [ ! -f "$INPUT_FILE" ]; then
    echo "BŁĄD: Nie znaleziono pliku $INPUT_FILE"
    exit 1
fi

# Iteracja po każdym wierszu pliku
while read -r haslo_maila nazwa_usera; do
    # Pomiń puste linie
    [[ -z "$haslo_maila" || -z "$nazwa_usera" ]] && continue

    # Jeśli nazwa zawiera @, to weź tylko część przed @
    if [[ "$nazwa_usera" == *"@"* ]]; then
        nazwa_usera="${nazwa_usera%%@*}"
    fi

    # Zamień wszystkie znaki niedozwolone na Windowsie na underscore
    # Usuwamy: / \ : | ? * < >
    nazwa_pliku="$nazwa_usera"
    nazwa_pliku="${nazwa_pliku//[\/]/_}"   # / → _
    nazwa_pliku="${nazwa_pliku//[\\]/_}"   # \ → _
    nazwa_pliku="${nazwa_pliku//[:]/\_}"   # : → _
    nazwa_pliku="${nazwa_pliku//[|]/_}"    # | → _
    nazwa_pliku="${nazwa_pliku//[\?]/_}"   # ? → _
    nazwa_pliku="${nazwa_pliku//[\*]/_}"   # * → _
    nazwa_pliku="${nazwa_pliku//[<]/_}"    # < → _
    nazwa_pliku="${nazwa_pliku//[>]/_}"    # > → _

    echo "Przetwarzanie: $nazwa_pliku..."

    # 1. Stwórz tymczasowy plik .txt z hasłem
    echo "$haslo_maila" > "./$OUTPUT_DIR/$nazwa_pliku.txt"

    # 2. Utwórz zaszyfrowany ZIP (używając ZipCrypto)
    # -p: hasło, -mem=ZipCrypto: szyfrowanie ZipCrypto (kompatybilne ze wszystkimi systemami)
    # -- oznacza koniec flag, wszystko po tym to nazwy plików
    "$COMMAND_7Z" a -p"$ZIP_PASSWORD" -mem=ZipCrypto -- "./$OUTPUT_DIR/$nazwa_pliku.zip" "./$OUTPUT_DIR/$nazwa_pliku.txt" > /dev/null

    # 3. Usuń plik .txt, zostawiając tylko ZIP
    rm "./$OUTPUT_DIR/$nazwa_pliku.txt"

done < "$INPUT_FILE"

echo "------------------------------------------"
echo "GOTOWE! Wszystkie pliki ZIP zostały utworzone."