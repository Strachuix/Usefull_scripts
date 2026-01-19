#!/bin/bash

# --- KONFIGURACJA EMAIL'A ---
FROM_EMAIL="spokropek@pujarex.pl"
FROM_PASSWORD="TUTAJ_WSTAW_SWOJE_HASLO"  # ⚠️ ZMIEŃ NA SWOJE HASŁO
SMTP_SERVER="smtp.ogicom.pl"
SMTP_PORT="587"
# ----------------------------

INPUT_FILE="lista.txt"          # Plik z listą maili
ATTACHMENTS_DIR="pass_zips"     # Folder z plikami ZIP
SUBJECT="Dane dostępowe"        # Temat maila
BODY="Witaj,\n\nW załączniku znajdziesz zaszyfrowany plik z Twoimi danymi dostępowymi.\n\nPozdrawiam"

# Sprawdzenie czy folder z załącznikami istnieje
if [ ! -d "$ATTACHMENTS_DIR" ]; then
    echo "❌ BŁĄD: Folder $ATTACHMENTS_DIR nie istnieje!"
    exit 1
fi

# Sprawdzenie czy plik ze zmienną hasła jest poprawnie uzupełniony
if [ "$FROM_PASSWORD" == "TUTAJ_WSTAW_SWOJE_HASLO" ]; then
    echo "❌ BŁĄD: Zmień hasło w zmiennej FROM_PASSWORD!"
    echo "Linia 5: FROM_PASSWORD=\"TUTAJ_WSTAW_SWOJE_HASLO\""
    exit 1
fi

# Iteracja po każdym wierszu z listą maili
while read -r haslo_maila email_adres; do
    # Pomiń puste linie
    [[ -z "$haslo_maila" || -z "$email_adres" ]] && continue
    
    # Wyodrębnij nazwę użytkownika (część przed @)
    if [[ "$email_adres" == *"@"* ]]; then
        nazwa_uzytkownika="${email_adres%%@*}"
    else
        nazwa_uzytkownika="$email_adres"
    fi
    
    # Zamień niedozwolone znaki na underscore (jak w generator.sh)
    nazwa_pliku="$nazwa_uzytkownika"
    nazwa_pliku="${nazwa_pliku//[\/]/_}"
    nazwa_pliku="${nazwa_pliku//[\\]/_}"
    nazwa_pliku="${nazwa_pliku//[:]/\_}"
    nazwa_pliku="${nazwa_pliku//[|]/_}"
    nazwa_pliku="${nazwa_pliku//[\?]/_}"
    nazwa_pliku="${nazwa_pliku//[\*]/_}"
    nazwa_pliku="${nazwa_pliku//[<]/_}"
    nazwa_pliku="${nazwa_pliku//[>]/_}"
    
    # Ścieżka do pliku ZIP
    ZIP_FILE="./$ATTACHMENTS_DIR/$nazwa_pliku.zip"
    
    # Sprawdzenie czy plik ZIP istnieje
    if [ ! -f "$ZIP_FILE" ]; then
        echo "⚠️  BRAK PLIKU: $ZIP_FILE dla adresu $email_adres"
        continue
    fi
    
    echo "📧 Wysyłam email do: $email_adres"
    
    # Przygotowanie wiadomości MIME z załącznikiem
    BOUNDARY="boundary_$(date +%s)"
    
    # Utworzenie tymczasowego pliku maila
    MAIL_FILE="/tmp/mail_$RANDOM.txt"
    
    {
        echo "From: $FROM_EMAIL"
        echo "To: $email_adres"
        echo "Subject: $SUBJECT"
        echo "MIME-Version: 1.0"
        echo "Content-Type: multipart/mixed; boundary=$BOUNDARY"
        echo ""
        echo "--$BOUNDARY"
        echo "Content-Type: text/plain; charset=UTF-8"
        echo "Content-Transfer-Encoding: 8bit"
        echo ""
        echo -e "$BODY"
        echo ""
        echo "--$BOUNDARY"
        echo "Content-Type: application/zip"
        echo "Content-Disposition: attachment; filename=\"$nazwa_pliku.zip\""
        echo "Content-Transfer-Encoding: base64"
        echo ""
        # Encode ZIP do base64
        base64 "$ZIP_FILE"
        echo ""
        echo "--$BOUNDARY--"
    } > "$MAIL_FILE"
    
    # Wysłanie maila za pomocą curl
    curl --url "smtp://$SMTP_SERVER:$SMTP_PORT" \
        --ssl-reqd \
        --mail-from "$FROM_EMAIL" \
        --mail-rcpt "$email_adres" \
        --user "$FROM_EMAIL:$FROM_PASSWORD" \
        --upload-file "$MAIL_FILE" \
        2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo "✓ Email wysłany pomyślnie do $email_adres"
    else
        echo "❌ BŁĄD przy wysyłaniu maila do $email_adres"
    fi
    
    # Usunięcie tymczasowego pliku
    rm "$MAIL_FILE"
    
done < "$INPUT_FILE"

echo ""
echo "------------------------------------------"
echo "✓ GOTOWE! Maile zostały wysłane."
