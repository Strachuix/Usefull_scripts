#!/bin/bash

INPUT="table.sql"

# 1. Wypisz numery linii zaczynających się od INSERT
grep -in '^INSERT' "$INPUT" | cut -d: -f1 > linie_all.txt

# 2. Zostaw co dziesiątą linię + ostatnią
total=$(wc -l < linie_all.txt)
awk -v total="$total" 'NR % 10 == 1 || NR == total' linie_all.txt > linie.txt

# 3. Dodaj numer końcowy pliku SQL jako granicę
sql_total=$(wc -l < "$INPUT")
echo $((sql_total+1)) >> linie.txt

# 4. Podziel plik SQL według wybranych linii
mapfile -t lines < linie.txt
for ((i=0; i<${#lines[@]}-1; i++)); do
    start=${lines[$i]}
    end=$((lines[$i+1]-1))
    out="fragment_$((i+1)).sql"

    echo "Tworzę $out: linie $start-$end"
    sed -n "${start},${end}p" "$INPUT" > "$out"
done