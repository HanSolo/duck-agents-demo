@echo off
rem Stops the Duck agents demo on Windows. The data of the therapy clinic is kept (reset-demo deletes it).
cd /d "%~dp0"
where docker >nul 2>&1 || set "PATH=%ProgramFiles%\Docker\Docker\resources\bin;%PATH%"
docker compose down
if not errorlevel 1 echo The demo is stopped.
pause
