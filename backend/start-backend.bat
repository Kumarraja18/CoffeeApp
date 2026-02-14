@echo off
setlocal enabledelayedexpansion

echo ========================================
echo   Brew ^& Co — Starting Backend
echo ========================================
echo.

:: ------------------------------------------
:: Load .env file if it exists
:: ------------------------------------------
set "ENV_FILE=%~dp0..\.env"
if exist "%ENV_FILE%" (
    echo Loading environment from .env file...
    for /f "usebackq eol=# tokens=1,* delims==" %%A in ("%ENV_FILE%") do (
        if not "%%A"=="" if not "%%B"=="" (
            set "%%A=%%B"
        )
    )
    echo ✓ Environment loaded.
) else (
    echo ⚠ No .env file found at %ENV_FILE%
    echo   Using defaults: DB_USERNAME=root, DB_PASSWORD=empty
    echo   Create a .env file from .env.example for custom settings.
    echo.
)

:: ------------------------------------------
:: Set smart defaults if not already set
:: ------------------------------------------
if not defined DB_NAME set "DB_NAME=brewco_db"
if not defined DB_USERNAME set "DB_USERNAME=root"
if not defined DB_PASSWORD set "DB_PASSWORD="
if not defined ADMIN_EMAIL set "ADMIN_EMAIL=admin@brewco.com"
if not defined ADMIN_PASSWORD set "ADMIN_PASSWORD=admin123"
if not defined MAIL_USERNAME set "MAIL_USERNAME="
if not defined MAIL_PASSWORD set "MAIL_PASSWORD="

echo.
echo Configuration:
echo   Database:  %DB_NAME% (user: %DB_USERNAME%)
echo   Admin:     %ADMIN_EMAIL%
echo   Mail from: %MAIL_USERNAME%
if "%MAIL_USERNAME%"=="" (
    echo   ⚠ MAIL_USERNAME is empty — emails will be logged to console only
) else (
    echo   ✓ Email configured — approval emails will be sent via SMTP
)
echo.

echo Starting Spring Boot...
echo ========================================
mvn spring-boot:run
