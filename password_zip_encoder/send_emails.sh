#!/bin/bash

# --- TRYB DEBUG ---
DEBUG=1  # Zmień na 1 aby włączyć debugowanie i pełny log
DEBUG_FILE="send_emails_debug.log"
# ---

# --- KONFIGURACJA WIADOMOŚCI ---
SUBJECT="Dane dostępowe"
BODY="Example text"
# ----------------------------

# Funkcja logowania dla debug
debug_log() {
    if [ $DEBUG -eq 1 ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$DEBUG_FILE"
    fi
}

# Czyszczenie debug logu
if [ $DEBUG -eq 1 ]; then
    > "$DEBUG_FILE"
    echo "🔍 TRYB DEBUG WŁĄCZONY - Logs zapisywane do: $DEBUG_FILE"
    echo ""
fi

# --- KONFIGURACJA PLIKÓW --- 
CONFIG_FILE="smtp_config.txt"
EMAILS_FILE="emails.txt"
ATTACHMENTS_DIR="pass_zips"
# ----------------------------

# Sprawdzenie czy plik konfiguracyjny istnieje
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ BŁĄD: Plik $CONFIG_FILE nie istnieje!"
    exit 1
fi

if [ ! -f "$EMAILS_FILE" ]; then
    echo "❌ BŁĄD: Plik $EMAILS_FILE nie istnieje!"
    exit 1
fi

# Wczytanie zmiennych z pliku
source "$CONFIG_FILE"

# Sprawdzenie czy wszystkie zmienne są uzupełnione
if [ -z "$FROM_EMAIL" ] || [ -z "$FROM_PASSWORD" ] || [ -z "$SMTP_SERVER" ] || [ -z "$SMTP_PORT" ]; then
    echo "❌ BŁĄD: Brakuje danych w pliku $CONFIG_FILE"
    exit 1
fi

if [ "$FROM_PASSWORD" == "WSTAW_SWOJE_HASLO" ]; then
    echo "❌ BŁĄD: Zmień hasło w pliku $CONFIG_FILE!"
    exit 1
fi

# Sprawdzenie czy folder z załącznikami istnieje
if [ ! -d "$ATTACHMENTS_DIR" ]; then
    echo "❌ BŁĄD: Folder $ATTACHMENTS_DIR nie istnieje!"
    exit 1
fi

# --- TEST LOGOWANIA ---
echo "🔐 Testuję logowanie do SMTP..."
TEST_MAIL="/tmp/test_mail_$RANDOM.txt"

{
    echo "From: $FROM_EMAIL"
    echo "To: $FROM_EMAIL"
    echo "Subject: TEST"
    echo ""
    echo "Test"
} > "$TEST_MAIL"

TEST_OUTPUT=$(curl --url "smtp://$SMTP_SERVER:$SMTP_PORT" \
    --ssl-reqd \
    --mail-from "$FROM_EMAIL" \
    --mail-rcpt "$FROM_EMAIL" \
    --user "$FROM_EMAIL:$FROM_PASSWORD" \
    --upload-file "$TEST_MAIL" \
    2>&1)

TEST_EXIT_CODE=$?
rm "$TEST_MAIL"

if [ $TEST_EXIT_CODE -ne 0 ]; then
    echo "❌ BŁĄD: Nie udało się zalogować do SMTP!"
    echo ""
    echo "Detale błędu:"
    echo "$TEST_OUTPUT"
    echo ""
    echo "Sprawdź:"
    echo "  - Email: $FROM_EMAIL"
    echo "  - Hasło: (zmienione?)"
    echo "  - SMTP Server: $SMTP_SERVER"
    echo "  - Port: $SMTP_PORT"
    exit 1
fi

echo "✓ Logowanie poprawne!"
echo ""

# --- LICZNIKI ---
SENT=0
FAILED=0
SKIPPED=0

# Debugowanie - pokaż ile linii ma plik
EMAIL_COUNT=$(grep -c . "$EMAILS_FILE" 2>/dev/null || echo 0)
debug_log "Plik $EMAILS_FILE ma $EMAIL_COUNT linii"
echo "📋 Przetwarzam plik: $EMAILS_FILE ($EMAIL_COUNT linii)"
echo ""

# Konwersja CRLF do LF (Windows to Unix) - kompatybilne rozwiązanie
tr -d '\r' < "$EMAILS_FILE" > "${EMAILS_FILE}.tmp" 2>/dev/null && mv "${EMAILS_FILE}.tmp" "$EMAILS_FILE" 2>/dev/null || true
debug_log "Konwersja linii zakończona"

# Iteracja po każdym emailu z pliku emails.txt
debug_log "Otwieram plik do czytania: $EMAILS_FILE"
while IFS= read -r email_adres || [ -n "$email_adres" ]; do
    debug_log "Przeczytano linię (raw): '$email_adres'"
    
    # Pomiń puste linie
    [[ -z "$email_adres" ]] && {
        debug_log "Pusta linia - pominięto"
        continue
    }
    
    # Pomiń linie zaczynające się od #
    [[ "$email_adres" == \#* ]] && {
        debug_log "Pominięto komentarz: $email_adres"
        continue
    }
    
    # Usuń białe znaki na początku i końcu
    email_adres=$(echo "$email_adres" | xargs)
    debug_log "Czytam email z pliku: '$email_adres'"
    
    # Wyodrębnij nazwę użytkownika (część przed @)
    if [[ "$email_adres" == *"@"* ]]; then
        nazwa_uzytkownika="${email_adres%%@*}"
    else
        # Jeśli nie ma @, użyj całego emaila jako nazwy
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
        echo "⚠️  POMINIĘTO: Brak pliku $ZIP_FILE dla $email_adres"
        ((SKIPPED++))
        continue
    fi
    
    echo "📧 Wysyłam email do: $email_adres"
    
    # Przygotowanie wiadomości MIME z załącznikiem
    BOUNDARY="boundary_$(date +%s)"
    
    # Utworzenie tymczasowego pliku maila
    MAIL_FILE="/tmp/mail_$RANDOM.txt"
    
    debug_log "Plik ZIP: $ZIP_FILE"
    debug_log "Rozmiar ZIP: $(stat -f%z "$ZIP_FILE" 2>/dev/null || stat -c%s "$ZIP_FILE" 2>/dev/null) bajtów"
    debug_log "Email docelowy: $email_adres"
    
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
    SEND_OUTPUT=$(curl --url "smtp://$SMTP_SERVER:$SMTP_PORT" \
        --ssl-reqd \
        --mail-from "$FROM_EMAIL" \
        --mail-rcpt "$email_adres" \
        --user "$FROM_EMAIL:$FROM_PASSWORD" \
        --upload-file "$MAIL_FILE" \
        --verbose \
        2>&1)
    
    SEND_EXIT_CODE=$?
    
    # Logowanie w debug
    if [ $DEBUG -eq 1 ]; then
        debug_log "=== EMAIL: $email_adres ==="
        debug_log "Kod wyjścia curl: $SEND_EXIT_CODE"
        debug_log "Output serwera:"
        debug_log "$SEND_OUTPUT"
        debug_log "=========================="
    fi
    
    # Sprawdzenie czy odpowiedź zawiera kod sukcesu SMTP (250)
    # Kod 250 oznacza że serwer zaakceptował email
    if [ $SEND_EXIT_CODE -eq 0 ] && echo "$SEND_OUTPUT" | grep -q "250 "; then
        echo "✓ Email wysłany pomyślnie do $email_adres"
        ((SENT++))
    else
        echo "❌ BŁĄD przy wysyłaniu maila do $email_adres"
        echo "   Kod wyjścia curl: $SEND_EXIT_CODE"
        
        # Wyodrębnienie kodu odpowiedzi SMTP z verbose output
        SMTP_CODE=$(echo "$SEND_OUTPUT" | grep -oP '^< \d{3}' | tail -1 | grep -oP '\d{3}')
        if [ -n "$SMTP_CODE" ]; then
            echo "   Kod SMTP: $SMTP_CODE"
            case $SMTP_CODE in
                550) echo "   Przyczyna: Recipient rejected - możliwy błędny adres email" ;;
                451) echo "   Przyczyna: Service unavailable - spróbuj ponownie" ;;
                452) echo "   Przyczyna: Insufficient storage - za dużo wiadomości" ;;
                535) echo "   Przyczyna: Authentication failed - błędne hasło/email" ;;
                *) echo "   Pełny błąd: $(echo "$SEND_OUTPUT" | grep -oP '^\< .*' | head -5)" ;;
            esac
        fi
        
        ((FAILED++))
    fi
    
    # Usunięcie tymczasowego pliku
    rm "$MAIL_FILE"
    
done < "$EMAILS_FILE"

echo ""
echo "------------------------------------------"
echo "📊 PODSUMOWANIE:"
echo "   ✓ Wysłane:  $SENT"
echo "   ❌ Błędy:   $FAILED"
echo "   ⚠️  Pominięte: $SKIPPED"
echo "------------------------------------------"

if [ $DEBUG -eq 1 ]; then
    echo ""
    echo "📄 Pełny log debugowania: $DEBUG_FILE"
fi
