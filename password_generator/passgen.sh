#!/bin/bash

# Konfiguracja
PREFIX="JX"
CHARS="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%"
PULPIT="$HOME/Desktop"
TARGET_LENGTH=12

# Automatyczne obliczenie długości suffixu
PREFIX_LENGTH=${#PREFIX}
SUFFIX_LENGTH=$((TARGET_LENGTH - PREFIX_LENGTH))

# Suffx musi mieć co najmniej 4 znaki
if [ $SUFFIX_LENGTH -lt 4 ]; then
    SUFFIX_LENGTH=4
fi

echo "============================================"
echo "      GENERATOR HASEŁ $PREFIX ($TARGET_LENGTH ZNAKÓW)     "
echo "============================================"

# Zapytanie o ilość haseł
read -p "Ile haseł wygenerować? " ILE

# Walidacja czy podano liczbę
if ! [[ "$ILE" =~ ^[0-9]+$ ]]; then
    echo "Błąd: Podaj poprawną liczbę!"
    exit 1
fi

# Logika nazewnictwa plików (hasla.txt, hasla_1.txt, itd.)
FILE_PATH="$PULPIT/hasla.txt"
if [ -f "$FILE_PATH" ]; then
    COUNT=1
    while [ -f "$PULPIT/hasla_$COUNT.txt" ]; do
        ((COUNT++))
    done
    FILE_PATH="$PULPIT/hasla_$COUNT.txt"
fi

echo "Lista wygenerowanych haseł ($(date))" > "$FILE_PATH"
echo "--------------------------------------------" >> "$FILE_PATH"

echo -e "\nGenerowanie haseł..."

for ((i=1; i<=ILE; i++)); do
    while true; do
        # Generowanie losowych znaków (długość automatycznie dostosowana)
        # Używamy /dev/urandom dla bezpieczeństwa kryptograficznego
        SUFFIX=$(LC_ALL=C tr -dc "$CHARS" < /dev/urandom | head -c $SUFFIX_LENGTH)
        PASS="${PREFIX}${SUFFIX}"
        
        # Sprawdzanie reguł (mała, wielka, cyfra, specjalny)
        if [[ "$PASS" =~ [a-z] ]] && \
           [[ "$PASS" =~ [A-Z] ]] && \
           [[ "$PASS" =~ [0-9] ]] && \
           [[ "$PASS" =~ [!@#$%] ]]; then
            break
        fi
    done
    
    echo "Hasło $i: $PASS"
    echo "$PASS" >> "$FILE_PATH"
done

echo -e "\n--------------------------------------------"
echo "Gotowe! Hasła zapisano w: $FILE_PATH"
read -p "Naciśnij Enter, aby zakończyć..."