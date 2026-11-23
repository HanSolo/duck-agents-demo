@echo off
rem Stops the Duck agents demo on Windows and deletes its data, so the next start begins fresh.
cd /d "%~dp0"
rem Image names must be lower case; GitHub names often are not, so lower-case the prefix from .env (the environment value wins over .env)
for /f "usebackq delims=" %%i in (`powershell -NoProfile -Command "$l = Select-String -Path '.env' -Pattern '^DEMO_IMAGE_PREFIX='; if ($l) { ($l[-1].Line -replace '^DEMO_IMAGE_PREFIX=','').Trim().Trim('\"').ToLower() }"`) do set "DEMO_IMAGE_PREFIX=%%i"
where docker >nul 2>&1 || set "PATH=%ProgramFiles%\Docker\Docker\resources\bin;%PATH%"
set /p answer=This deletes all bookings and changes made during demos. Type yes to continue: 
if /i "%answer%"=="yes" (
  docker compose down -v
  echo The demo is reset. Start it again with start-demo.
) else (
  echo Nothing was changed.
)
pause
