@echo off
setlocal enabledelayedexpansion

echo ========================================================
echo   Brew ^& Co — Universal MySQL Database Setup
echo   Works on any Windows machine with MySQL installed
echo ========================================================
echo.

:: ------------------------------------------
:: Step 1: Find MySQL
:: ------------------------------------------
echo [Step 1/4] Finding MySQL installation...

set "MYSQL_CMD="

:: Check if mysql is in PATH
where mysql >nul 2>&1
if %errorlevel% equ 0 (
    set "MYSQL_CMD=mysql"
    echo ✓ Found mysql in PATH.
    goto :found_mysql
)

:: Search common install locations
set "SEARCH_PATHS=C:\Program Files\MySQL;C:\ProgramData\MySQL;C:\MySQL;D:\MySQL;C:\xampp\mysql;D:\xampp\mysql"

for %%P in (%SEARCH_PATHS%) do (
    if exist "%%P" (
        for /r "%%P" %%F in (mysql.exe) do (
            if exist "%%F" (
                set "MYSQL_CMD=%%F"
                echo ✓ Found MySQL at: %%F
                goto :found_mysql
            )
        )
    )
)

:: Last attempt — search Program Files recursively
for /r "C:\Program Files\MySQL" %%F in (mysql.exe) do (
    if exist "%%F" (
        set "MYSQL_CMD=%%F"
        echo ✓ Found MySQL at: %%F
        goto :found_mysql
    )
)

echo ✗ ERROR: MySQL not found on this system.
echo.
echo   Please install MySQL 8.x from:
echo   https://dev.mysql.com/downloads/installer/
echo.
echo   After installing, add MySQL\bin to your system PATH,
echo   or re-run this script.
echo.
pause
exit /b 1

:found_mysql

:: ------------------------------------------
:: Step 2: Start MySQL Service  
:: ------------------------------------------
echo.
echo [Step 2/4] Starting MySQL service...

:: Try common MySQL service names
set "MYSQL_STARTED=0"
for %%S in (MySQL80 MySQL MySQL57 MySQL56 MySQLServer MySQLService) do (
    net start %%S >nul 2>&1
    if !errorlevel! equ 0 (
        echo ✓ Started MySQL service: %%S
        set "MYSQL_STARTED=1"
        goto :service_ok
    )
    if !errorlevel! equ 2 (
        echo ✓ MySQL service already running: %%S
        set "MYSQL_STARTED=1"
        goto :service_ok
    )
)

:: Check if MySQL is responding even without service management
"%MYSQL_CMD%" -u root --connect-timeout=3 -e "SELECT 1;" >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ MySQL is responding (running as process).
    set "MYSQL_STARTED=1"
    goto :service_ok
)

echo ⚠ Could not auto-start MySQL service.
echo   Please start MySQL manually (MySQL Workbench or Services panel).
echo   Then press any key to continue...
pause >nul

:service_ok

:: ------------------------------------------
:: Step 3: Get MySQL root password
:: ------------------------------------------
echo.
echo [Step 3/4] MySQL root credentials...
echo.

:: Check if .env has DB_PASSWORD
set "ROOT_PASS="
if exist "%~dp0.env" (
    for /f "usebackq tokens=1,* delims==" %%A in ("%~dp0.env") do (
        if "%%A"=="DB_PASSWORD" set "ROOT_PASS=%%B"
        if "%%A"=="DB_USERNAME" set "DB_USER=%%B"
    )
)

if not defined DB_USER set "DB_USER=root"

:: Try connecting without password first (common on fresh installs)
"%MYSQL_CMD%" -u %DB_USER% --connect-timeout=5 -e "SELECT 1;" >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ Connected to MySQL as %DB_USER% (no password needed).
    set "ROOT_PASS="
    set "PASS_FLAG="
    goto :connected
)

:: Try with password from .env
if defined ROOT_PASS (
    "%MYSQL_CMD%" -u %DB_USER% -p%ROOT_PASS% --connect-timeout=5 -e "SELECT 1;" >nul 2>&1
    if !errorlevel! equ 0 (
        echo ✓ Connected to MySQL using .env credentials.
        set "PASS_FLAG=-p%ROOT_PASS%"
        goto :connected
    )
)

:: Ask user for password
echo   Could not connect automatically.
set /p "ROOT_PASS=  Enter MySQL root password: "

"%MYSQL_CMD%" -u root -p%ROOT_PASS% --connect-timeout=5 -e "SELECT 1;" >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo ✗ ERROR: Could not connect to MySQL with provided password.
    echo   Please verify your MySQL root password and try again.
    pause
    exit /b 1
)
set "DB_USER=root"
set "PASS_FLAG=-p%ROOT_PASS%"
echo ✓ Connected successfully!

:connected

:: ------------------------------------------
:: Step 4: Setup Database
:: ------------------------------------------
echo.
echo [Step 4/4] Setting up brewco_db database...

:: Create database
"%MYSQL_CMD%" -u %DB_USER% %PASS_FLAG% -e "CREATE DATABASE IF NOT EXISTS brewco_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>nul
if %errorlevel% neq 0 (
    echo ✗ ERROR: Failed to create database.
    pause
    exit /b 1
)
echo ✓ Database 'brewco_db' is ready.

:: Ask if user wants to import existing data
echo.
if exist "%~dp0backend\src\main\resources\brewco_db.sql" (
    echo   Found existing data file: brewco_db.sql
    echo   This contains sample users and table structure.
    set /p "IMPORT_DATA=  Import existing data? (y/N): "
    if /i "!IMPORT_DATA!"=="y" (
        "%MYSQL_CMD%" -u %DB_USER% %PASS_FLAG% < "%~dp0backend\src\main\resources\brewco_db.sql" 2>nul
        if !errorlevel! equ 0 (
            echo ✓ Data imported successfully!
        ) else (
            echo ⚠ Import had warnings (tables may already exist - this is OK).
        )
    ) else (
        echo   Skipped. Hibernate will create tables on first boot.
    )
)

:: ------------------------------------------
:: Generate/Update .env file
:: ------------------------------------------
echo.
echo Updating .env file...

:: Only create .env if it doesn't exist
if not exist "%~dp0.env" (
    (
        echo # Brew ^& Co - Local Environment Variables
        echo # Auto-generated by setup.bat
        echo.
        echo # Database
        echo DB_NAME=brewco_db
        echo DB_USERNAME=%DB_USER%
        echo DB_PASSWORD=%ROOT_PASS%
        echo.
        echo # Admin Account ^(created on first startup^)
        echo ADMIN_EMAIL=admin@brewco.com
        echo ADMIN_PASSWORD=admin123
        echo.
        echo # Email ^(Gmail SMTP^) - Optional, app works without it
        echo MAIL_USERNAME=
        echo MAIL_PASSWORD=
    ) > "%~dp0.env"
    echo ✓ Created .env file with your MySQL credentials.
) else (
    echo ✓ .env file already exists. Not overwriting.
)

echo.
echo ========================================================
echo   ✓ Setup Complete!
echo ========================================================
echo.
echo   Database: brewco_db (MySQL)
echo   User:     %DB_USER%
echo.
echo   Next steps:
echo     1. Edit .env to add your Gmail SMTP credentials (optional)
echo     2. Run SETUP_AND_RUN.bat to start everything!
echo        Or run backend\start-backend.bat + frontend\npm run dev
echo.
echo ========================================================
pause
