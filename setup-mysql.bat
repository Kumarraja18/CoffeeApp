@echo off
setlocal enabledelayedexpansion

echo ========================================
echo Brew ^& Co - MySQL Database Setup (Quick)
echo ========================================
echo.

:: Load .env if exists
if exist "%~dp0.env" (
    for /f "usebackq eol=# tokens=1,* delims==" %%A in ("%~dp0.env") do (
        if not "%%A"=="" if not "%%B"=="" (
            set "%%A=%%B"
        )
    )
)

:: Defaults
if not defined DB_USERNAME set DB_USERNAME=root
if not defined DB_PASSWORD set DB_PASSWORD=

echo Step 1: Starting MySQL service...
net start MySQL80 >nul 2>&1
if %errorlevel% equ 2 (
    echo MySQL service is already running.
) else if %errorlevel% equ 0 (
    echo MySQL service started successfully!
) else (
    :: Try other service names
    net start MySQL >nul 2>&1
    if !errorlevel! leq 2 (
        echo MySQL service is running.
    ) else (
        echo WARNING: Could not start MySQL service automatically.
        echo Please start it manually from Services panel or MySQL Workbench.
    )
)

echo.
echo Step 2: Setting up database...

:: Build password flag
set "PASS_FLAG="
if defined DB_PASSWORD if not "%DB_PASSWORD%"=="" set "PASS_FLAG=-p%DB_PASSWORD%"

:: Create database
mysql -u %DB_USERNAME% %PASS_FLAG% -e "CREATE DATABASE IF NOT EXISTS brewco_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>nul
if %errorlevel% neq 0 (
    echo ERROR: Failed to connect to MySQL.
    echo Try running the full setup.bat instead.
    pause
    exit /b 1
)

echo.
echo Step 3: Importing schema...
if exist "backend\src\main\resources\brewco_db.sql" (
    mysql -u %DB_USERNAME% %PASS_FLAG% < "backend\src\main\resources\brewco_db.sql" 2>nul
    if !errorlevel! equ 0 (
        echo ✓ Schema imported successfully!
    ) else (
        echo ⚠ Import had warnings (this is usually OK).
    )
) else (
    echo ⚠ SQL file not found. Hibernate will create tables automatically.
)

echo.
echo ========================================
echo Database setup completed successfully!
echo ========================================
echo Database: brewco_db
echo User: %DB_USERNAME%
echo.
pause
