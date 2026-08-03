@echo off
title OpenCoder - Create PR
cd /d "%~dp0"

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\create_pr.ps1"

exit /b %errorlevel%
