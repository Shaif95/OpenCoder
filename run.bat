@echo off
title OpenCoder / Continue Development Launcher
:menu
cls
echo =====================================================================
echo              OpenCoder / Continue Development Launcher
echo =====================================================================
echo.
echo  [1] Setup: Install All Dependencies (PS1 script)
echo  [2] Watch: Start TypeScript Watchers (tsc:watch)
echo  [3] Build: Package VS Code Extension (.vsix)
echo  [4] GUI: Run Vite Dev Server for GUI
echo  [5] Docs: Run Local Documentation Server
echo  [6] Exit
echo.
echo =====================================================================
set /p opt="Select an option (1-6): "

if "%opt%"=="1" goto setup
if "%opt%"=="2" goto watch
if "%opt%"=="3" goto package
if "%opt%"=="4" goto gui
if "%opt%"=="5" goto docs
if "%opt%"=="6" goto exit
echo.
echo [ERROR] Invalid option, please try again.
pause
goto menu

:setup
echo.
echo [INFO] Running dependency setup script...
cd "%~dp0\continue"
powershell -ExecutionPolicy Bypass -File .\scripts\install-dependencies.ps1
cd "%~dp0"
echo.
echo [SUCCESS] Dependency installation finished.
pause
goto menu

:watch
echo.
echo [INFO] Starting TypeScript compile watchers. Press Ctrl+C to stop.
cd "%~dp0\continue"
call npm run tsc:watch
cd "%~dp0"
pause
goto menu

:package
echo.
echo [INFO] Packaging VS Code Extension...
cd "%~dp0\continue\extensions\vscode"
call npm run package
cd "%~dp0"
echo.
echo [SUCCESS] Packaging complete. Check continue/extensions/vscode/build for .vsix file.
pause
goto menu

:gui
echo.
echo [INFO] Starting GUI Dev Server...
cd "%~dp0\continue\gui"
call npm run dev
cd "%~dp0"
pause
goto menu

:docs
echo.
echo [INFO] Starting Documentation Dev Server...
cd "%~dp0\continue\docs"
call npm run dev
cd "%~dp0"
pause
goto menu

:exit
echo.
echo Exiting. Happy coding!
exit /b 0
