@echo off
rem Stops the Duck agents demo on Windows and deletes its data, so the next start begins fresh.
cd /d "%~dp0"
where docker >nul 2>&1 || set "PATH=%ProgramFiles%\Docker\Docker\resources\bin;%PATH%"
set /p answer=This deletes all bookings and changes made during demos. Type yes to continue: 
if /i "%answer%"=="yes" (
  docker compose down -v
  echo The demo is reset. Start it again with start-demo.
) else (
  echo Nothing was changed.
)
pause
