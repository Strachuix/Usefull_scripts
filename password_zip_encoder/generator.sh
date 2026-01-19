#!/bin/bash

# --- KONFIGURACJA ---
INPUT_FILE="lista.txt"      # Nazwa Twojego pliku wejściowego
ZIP_PASSWORD="TwojeHaslo"   # Hasło, którym będą zabezpieczone wszystkie ZIPy
# --------------------

# Sprawdź czy 7-zip (7z) jest zainstalowany
if ! command -v 7z &> /dev/null; then
    echo "BŁĄD: Program 7z nie jest zainstalowany. Zainstaluj go (np. sudo apt install p7zip-full)."
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

    echo "Przetwarzanie: $nazwa_usera..."

    # 1. Stwórz tymczasowy plik .txt z hasłem
    echo "$haslo_maila" > "$nazwa_usera.txt"

    # 2. Utwórz zaszyfrowany ZIP (używając AES-256)
    # -p: hasło, -mem=AES256: silne szyfrowanie, -y: potwierdzaj wszystko
    7z a -p"$ZIP_PASSWORD" -mem=AES256 "$nazwa_usera.zip" "$nazwa_usera.txt" > /dev/null

    # 3. Usuń plik .txt, zostawiając tylko ZIP
    rm "$nazwa_usera.txt"

done < "$INPUT_FILE"

echo "------------------------------------------"
echo "GOTOWE! Wszystkie pliki ZIP zostały utworzone."