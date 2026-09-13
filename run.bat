@echo off
title myprojects
cd /d "%~dp0"

echo.
echo  ============================================
echo   myprojects.cc
echo  ============================================
echo.

where python >nul 2>&1
if errorlevel 1 goto nopython

set CADDY=
if exist "caddy.exe" set CADDY=%~dp0caddy.exe
if "%CADDY%"=="" if exist "C:\Caddy\caddy.exe" set CADDY=C:\Caddy\caddy.exe
if "%CADDY%"=="" for /f "delims=" %%C in ('where caddy 2^>nul') do set CADDY=%%C
if "%CADDY%"=="" goto nocaddy

if not exist "Caddyfile" goto nocaddyfile
if not exist "warroom\server.py" goto nowarroom
if not exist "site\index.html" goto nosite

findstr /c:"REPLACE_WITH_HASH" Caddyfile >nul 2>&1
if not errorlevel 1 goto nohash

sc query caddy >nul 2>&1
if not errorlevel 1 (
  echo  A Caddy Windows service is installed and would fight this window
  echo  for ports 80 and 443. Stop it first:
  echo.
  echo      sc stop caddy
  echo.
  pause
)

if not exist "warroom\state.json" (
  echo  NOTE: warroom\state.json is missing.
  echo  If you are moving from C:\WarRoom, copy these across first or the
  echo  site starts empty:
  echo      state.json  password.txt  .secret  uploads\  backups\
  echo.
)

if not exist "lol\index.html" (
  echo  NOTE: lol\ has no index.html yet. Point League Vault's
  echo  "Your server" path at:  %~dp0lol
  echo.
)

"%CADDY%" validate --config Caddyfile >nul 2>&1
if errorlevel 1 (
  echo  The Caddyfile has a problem. Caddy says:
  echo.
  "%CADDY%" validate --config Caddyfile
  echo.
  pause
  exit /b
)

echo  Starting the War Room on 127.0.0.1:8081 (this machine only) ...
start "myprojects-warroom" /min /d "%~dp0warroom" cmd /c "python server.py 8081 local >> server.log 2>&1"

echo  Starting Caddy on ports 80 and 443 ...
echo.
echo   front page   https://myprojects.cc
echo   league       https://lol.myprojects.cc
echo   war room     https://rok.myprojects.cc
echo.
echo  Leave this window OPEN. Closing it stops everything.
echo.

"%CADDY%" run --config Caddyfile

echo.
echo  Caddy stopped - shutting the War Room down too.
taskkill /fi "WINDOWTITLE eq myprojects-warroom*" /f >nul 2>&1
echo.
pause
exit /b

:nopython
echo  Python is not installed, or not on PATH.
echo  https://www.python.org/downloads/  - tick "Add python.exe to PATH".
echo.
pause
exit /b

:nocaddy
echo  caddy.exe was not found.
echo.
echo  Put it next to this file, or in C:\Caddy\, or on PATH.
echo  https://caddyserver.com/download  (Windows amd64)
echo.
pause
exit /b

:nocaddyfile
echo  Caddyfile is missing from this folder.
echo.
pause
exit /b

:nowarroom
echo  warroom\server.py is missing.
echo  Copy the contents of the project's selfhost\ folder into warroom\.
echo.
pause
exit /b

:nosite
echo  site\index.html is missing - that is the front page.
echo.
pause
exit /b

:nohash
echo  The Caddyfile still says REPLACE_WITH_HASH, so the password would
echo  not work. Make a hash and paste it in:
echo.
echo      "%CADDY%" hash-password
echo.
pause
exit /b
