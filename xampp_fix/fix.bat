@echo off
:: Upewnij sie, ze sciezka do XAMPP jest poprawna
set XAMPP_PATH=C:\xampp

echo === Rozpoczynanie naprawy MySQL w XAMPP ===
taskkill /f /im mysqld.exe >nul 2>&1

cd /d "%XAMPP_PATH%\mysql"

echo 1. Tworzenie kopii zapasowej biezacego folderu data...
if exist data_old rmdir /s /q data_old
rename data data_old

echo 2. Tworzenie nowej struktury z folderu backup...
mkdir data
xcopy /e /q backup data

echo 3. Przywracanie Twoich baz danych...
:: Kopiuje foldery baz danych (z pominięciem systemowych)
for /d %%i in (data_old\*) do (
    set "dirname=%%~nxi"
    if /i not "%%~nxi"=="mysql" if /i not "%%~nxi"=="performance_schema" if /i not "%%~nxi"=="phpmyadmin" if /i not "%%~nxi"=="test" (
        echo Kopiowanie bazy: %%~nxi
        xcopy /e /q "%%i" "data\%%~nxi\"
    )
)

echo 4. Przywracanie kluczowego pliku ibdata1...
copy /y data_old\ibdata1 data\ibdata1

echo === Naprawa zakonczona! Mozesz teraz uruchomic MySQL w XAMPP ===
pause