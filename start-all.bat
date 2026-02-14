@echo off
setlocal enabledelayedexpansion

echo ========================================
echo Starting Brew ^& Co Application
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

:: Apply defaults
if not defined DB_NAME set DB_NAME=brewco_db
if not defined DB_USERNAME set DB_USERNAME=root
if not defined DB_PASSWORD set DB_PASSWORD=
if not defined ADMIN_EMAIL set ADMIN_EMAIL=admin@brewco.com
if not defined ADMIN_PASSWORD set ADMIN_PASSWORD=admin123

:: Ensure MySQL is running
for %%S in (MySQL80 MySQL MySQL57) do (
    net start %%S >nul 2>&1
    if !errorlevel! leq 2 goto :mysql_ok
)
echo ⚠ Could not auto-start MySQL. Assuming it is already running...
:mysql_ok

echo Starting Backend (Spring Boot)...
start "BrewCo Backend" cmd /k "cd /d "%~dp0backend" && start-backend.bat"

timeout /t 8 /nobreak >nul

echo Starting Frontend (Vite + React)...
start "BrewCo Frontend" cmd /k "cd /d "%~dp0frontend" && npm run dev"

echo.
echo ========================================
echo Application Started!
echo ========================================
echo Backend: http://localhost:8080
echo Frontend: http://localhost:5173
echo.
echo Press any key to exit this window...
pause >nul
