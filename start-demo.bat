@echo off
rem Starts the Duck agents demo on Windows. Double-click this file in Explorer.
setlocal EnableDelayedExpansion
cd /d "%~dp0"
rem Image names must be lower case; GitHub names often are not, so lower-case the prefix from .env (the environment value wins over .env)
for /f "usebackq delims=" %%i in (`powershell -NoProfile -Command "$l = Select-String -Path '.env' -Pattern '^DEMO_IMAGE_PREFIX='; if ($l) { ($l[-1].Line -replace '^DEMO_IMAGE_PREFIX=','').Trim().Trim('\"').ToLower() }"`) do set "DEMO_IMAGE_PREFIX=%%i"
echo === Duck agents demo ===

rem 1. Docker installed and running?
where docker >nul 2>&1
if errorlevel 1 (
  if exist "%ProgramFiles%\Docker\Docker\resources\bin\docker.exe" (
    set "PATH=%ProgramFiles%\Docker\Docker\resources\bin;!PATH!"
  ) else (
    call :stop_here "Docker is not installed. Please install Docker Desktop (ask IT), start it once, then try again."
    exit /b 1
  )
)
docker info >nul 2>&1
if not errorlevel 1 goto docker_ready
echo Starting Docker Desktop ...
if exist "%ProgramFiles%\Docker\Docker\Docker Desktop.exe" start "" "%ProgramFiles%\Docker\Docker\Docker Desktop.exe"
set /a tries=0
:wait_docker
timeout /t 3 /nobreak >nul
docker info >nul 2>&1
if not errorlevel 1 goto docker_ready
set /a tries+=1
if !tries! lss 60 goto wait_docker
call :stop_here "Docker Desktop did not start. Open it from the Start menu, wait until it says it is running, then try again."
exit /b 1
:docker_ready

rem 2. Model settings
if not exist llm.env (
  copy /y llm.env.example llm.env >nul
  start "" notepad llm.env
  call :stop_here "First start: the file llm.env was created and opened in Notepad. Fill in the model name and the API key, save it, then double-click start-demo again."
  exit /b 1
)
findstr /r /c:"^[^#]*PASTE-" llm.env >nul
if not errorlevel 1 (
  start "" notepad llm.env
  call :stop_here "llm.env still contains PASTE-... placeholders. Fill in the model name and the API key, save it, then double-click start-demo again."
  exit /b 1
)

rem 3. Ports free? (skipped when the demo is already running)
set "running="
for /f %%c in ('docker compose ps -q 2^>nul') do set "running=yes"
if not defined running (
  for %%p in (8080 8081 8082) do (
    netstat -ano | findstr /r /c:"TCP.*:%%p .*LISTENING" >nul
    if not errorlevel 1 (
      call :stop_here "Port %%p is used by another program. Close it, or restart the computer, then try again."
      exit /b 1
    )
  )
)

rem 4. Start
echo Downloading updates (can take a few minutes the first time) ...
docker compose pull
if errorlevel 1 echo Could not download updates, starting the version already on this computer.
docker compose up -d
if errorlevel 1 (
  call :stop_here "The demo could not be started. Send a screenshot of this window to the demo maintainer."
  exit /b 1
)

rem 5. Wait until the three web pages answer, then open them
echo Waiting for the applications (usually 1 to 2 minutes) ...
call :wait_for "http://localhost:8080/duck-clinic/" "DuckClinic"
call :wait_for "http://localhost:8081/" "DuckInsurance"
call :wait_for "http://localhost:8082/" "Duck Physical Therapy Clinic"
start "" "http://localhost:8080/duck-clinic/"
start "" "http://localhost:8081/"
start "" "http://localhost:8082/"

echo.
echo The demo is running. DuckInsurance sign-in: admin / admin (also adjuster / adjuster, customer / customer).
echo Stop it with stop-demo when you are done.
pause
exit /b 0

:wait_for
set /a w=0
:wait_loop
curl -s -f -o nul --max-time 5 %1 >nul 2>&1
if not errorlevel 1 (
  echo   %~2 is ready
  exit /b 0
)
set /a w+=1
if !w! geq 100 (
  echo   %~2 did not answer in time, opening it anyway
  exit /b 0
)
timeout /t 3 /nobreak >nul
goto wait_loop

:stop_here
echo.
echo %~1
echo.
pause
exit /b 0
