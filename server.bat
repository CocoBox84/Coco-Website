rem Some old code that is no no longer needed
@echo off
title Coco Website Dev Server
color 0A

cd D:\Coco Website

echo cd

echo Checking MongoDB service status...
sc query MongoDB | find "RUNNING" >nul
if errorlevel 1 (
    echo MongoDB service is not running. Starting it now...
    net start MongoDB
) else (
    echo MongoDB service is already running.
)

echo.
echo ================================
echo Starting Coco Website server...
echo ================================
node server.js

echo.
echo [!] Node server stopped. Press any key to close this window.
pause >nul
