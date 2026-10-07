@echo off
title Productos CRUD - CodeIgniter 3
cd /d "%~dp0"

set "PHP="
set "MYSQLBIN="
for /d %%D in ("C:\laragon\bin\php\*") do if exist "%%D\php.exe" set "PHP=%%D\php.exe"
for /d %%D in ("C:\laragon\bin\mysql\*") do if exist "%%D\bin\mysql.exe" set "MYSQLBIN=%%D\bin"
if not defined PHP if exist "C:\xampp\php\php.exe" set "PHP=C:\xampp\php\php.exe"
if not defined MYSQLBIN if exist "C:\xampp\mysql\bin\mysql.exe" set "MYSQLBIN=C:\xampp\mysql\bin"

if not defined PHP (
    echo No se encontro PHP de Laragon ni de XAMPP.
    pause
    exit /b
)
if not defined MYSQLBIN (
    echo No se encontro MySQL de Laragon ni de XAMPP.
    pause
    exit /b
)

echo PHP:   %PHP%
echo MySQL: %MYSQLBIN%
echo.

"%MYSQLBIN%\mysql.exe" -u root -e "SELECT 1" >nul 2>&1
if errorlevel 1 (
    echo Encendiendo MySQL...
    start "MySQL" /min "%MYSQLBIN%\mysqld.exe"
    timeout /t 8 /nobreak >nul
)

"%MYSQLBIN%\mysql.exe" -u root -e "SELECT 1" >nul 2>&1
if errorlevel 1 (
    echo No se pudo conectar a MySQL. Enciendelo desde Laragon o XAMPP y vuelve a abrir este archivo.
    pause
    exit /b
)

echo Preparando la base de datos productos_crud...
"%MYSQLBIN%\mysql.exe" -u root -e "source database/schema.sql"

echo.
echo La app esta en: http://localhost:8000/index.php/productos
echo NO cierres esta ventana mientras uses la app. Para apagarla, cierra la ventana.
echo.
start "" "http://localhost:8000/index.php/productos"
"%PHP%" -S localhost:8000
