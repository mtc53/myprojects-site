@echo off
title myprojects
cd /d "%~dp0"

REM The site is static now — this just serves site\ with Caddy. No password,
REM no python server. GitHub Pages is the default host; use this only if you
REM prefer to serve the same files from this machine.

set CADDY=
if exist "caddy.exe" set CADDY=%~dp0caddy.exe
if "%CADDY%"=="" if exist "C:\Caddy\caddy.exe" set CADDY=C:\Caddy\caddy.exe
if "%CADDY%"=="" for /f "delims=" %%C in ('where caddy 2^>nul') do set CADDY=%%C
if "%CADDY%"=="" goto nocaddy
if not exist "Caddyfile" goto nocaddyfile

"%CADDY%" run --config Caddyfile
goto :eof

:nocaddy
echo Caddy not found. Put caddy.exe in this folder, or install it on PATH.
echo https://caddyserver.com/download
pause
goto :eof

:nocaddyfile
echo No Caddyfile here. Copy Caddyfile.example to Caddyfile and edit the domain.
pause
