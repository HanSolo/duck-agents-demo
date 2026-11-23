@echo off
rem Stops the Duck agents demo on Windows. The data of the therapy clinic is kept (reset-demo deletes it).
cd /d "%~dp0"
rem Image names must be lower case; GitHub names often are not, so lower-case the prefix from .env (the environment value wins over .env)
for /f "usebackq delims=" %%i in (`powershell -NoProfile -Command "$l = Select-String -Path '.env' -Pattern '^DEMO_IMAGE_PREFIX='; if ($l) { ($l[-1].Line -replace '^DEMO_IMAGE_PREFIX=','').Trim().Trim('\"').ToLower() }"`) do set "DEMO_IMAGE_PREFIX=%%i"
where docker >nul 2>&1 || set "PATH=%ProgramFiles%\Docker\Docker\resources\bin;%PATH%"
docker compose down
if not errorlevel 1 echo The demo is stopped.
pause
