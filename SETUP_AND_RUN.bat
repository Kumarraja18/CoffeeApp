@echo off
setlocal enabledelayedexpansion

echo ================================================================
echo   ☕ Brew ^& Co — One-Click Setup ^& Run
echo   Plug-and-Play: Works on any Windows machine
echo ================================================================
echo.

:: ------------------------------------------
:: Check Prerequisites
:: ------------------------------------------
echo [1/5] Checking prerequisites...

:: Check Java
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo ✗ Java not found! Install JDK 17+ from:
    echo   https://adoptium.net/
    pause
    exit /b 1
)
for /f "tokens=3" %%v in ('java -version 2^>^&1 ^| findstr /i "version"') do (
    echo   ✓ Java: %%~v
)

:: Check Maven
call mvn -version >nul 2>&1
if %errorlevel% neq 0 (
    echo ✗ Maven not found! Install from:
    echo   https://maven.apache.org/download.cgi
    pause
    exit /b 1
)
echo   ✓ Maven found

:: Check Node.js
node -v >nul 2>&1
if %errorlevel% neq 0 (
    echo ✗ Node.js not found! Install from:
    echo   https://nodejs.org/
    pause
    exit /b 1
)
for /f %%v in ('node -v') do echo   ✓ Node.js: %%v

:: Check MySQL
where mysql >nul 2>&1
if %errorlevel% equ 0 (
    echo   ✓ MySQL found in PATH
) else (
    echo   ⚠ MySQL not in PATH (will try to find it automatically^)
)

echo.

:: ------------------------------------------
:: Load .env
:: ------------------------------------------
echo [2/5] Loading configuration...

if exist "%~dp0.env" (
    for /f "usebackq eol=# tokens=1,* delims==" %%A in ("%~dp0.env") do (
        if not "%%A"=="" if not "%%B"=="" (
            set "%%A=%%B"
        )
    )
    echo ✓ Loaded .env configuration
) else (
    echo ⚠ No .env file found. Using defaults.
    echo   Run setup.bat first for custom database credentials.
    set "DB_NAME=brewco_db"
    set "DB_USERNAME=root"
    set "DB_PASSWORD="
    set "ADMIN_EMAIL=admin@brewco.com"
    set "ADMIN_PASSWORD=admin123"
    set "MAIL_USERNAME="
    set "MAIL_PASSWORD="
)

:: Apply defaults for anything not set
if not defined DB_NAME set DB_NAME=brewco_db
if not defined DB_USERNAME set DB_USERNAME=root
if not defined DB_PASSWORD set DB_PASSWORD=
if not defined ADMIN_EMAIL set ADMIN_EMAIL=admin@brewco.com
if not defined ADMIN_PASSWORD set ADMIN_PASSWORD=admin123

echo.

:: ------------------------------------------
:: Start MySQL Service
:: ------------------------------------------
echo [3/5] Ensuring MySQL is running...

for %%S in (MySQL80 MySQL MySQL57 MySQL56 MySQLServer) do (
    net start %%S >nul 2>&1
    if !errorlevel! leq 2 (
        echo ✓ MySQL service is running
        goto :mysql_running
    )
)

echo ⚠ Could not auto-start MySQL. Assuming it's already running...

:mysql_running
echo.

:: ------------------------------------------
:: Install Frontend Dependencies (if needed)
:: ------------------------------------------
echo [4/5] Preparing frontend...

if not exist "%~dp0frontend\node_modules" (
    echo   Installing npm dependencies (first-time setup^)...
    cd /d "%~dp0frontend"
    npm install
    echo   ✓ Dependencies installed
) else (
    echo   ✓ Frontend dependencies already installed
)

echo.

:: ------------------------------------------
:: Start Both Servers
:: ------------------------------------------
echo [5/5] Starting application servers...
echo.

echo Starting Backend (Spring Boot on port 8080^)...
start "BrewCo Backend" cmd /k "cd /d "%~dp0backend" && start-backend.bat"

:: Wait for backend to initialize
echo Waiting for backend to start (10 seconds^)...
timeout /t 10 /nobreak >nul

echo Starting Frontend (Vite + React on port 5173^)...
start "BrewCo Frontend" cmd /k "cd /d "%~dp0frontend" && npm run dev"

echo.
echo ================================================================
echo   ☕ Brew ^& Co is starting up!
echo ================================================================
echo.
echo   ➤ Backend:   http://localhost:8080
echo   ➤ Frontend:  http://localhost:5173
echo.
echo   ➤ Admin Login:
echo     Email:    %ADMIN_EMAIL%
echo     Password: %ADMIN_PASSWORD%
echo.
echo   ➤ How it works:
echo     • Users register → Admin approves → Email sent with password
echo     • User logs in with emailed credentials
echo.
echo   ➤ Close this window anytime. Servers run independently.
echo ================================================================
echo.
pause
