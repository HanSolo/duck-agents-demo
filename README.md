# Duck agents demo

Three small web applications (a vet clinic, an insurer and a physiotherapy clinic) whose AI agents talk to each other.
This folder starts all three on your computer with one double-click.

## Before the first demo (once)

1. **Docker Desktop** must be installed. Ask IT: it needs administrator rights, and on Windows usually a restart.
   Start Docker Desktop once and accept its terms.
2. **Model settings:** double-click the start file (below). The first time, it creates the file `llm.env` and opens it.
   Paste in the model name and the API key you got from the demo maintainer, save the file, and double-click the start file again.
   Keep `llm.env` to yourself: it contains a key that costs money when used.

## Start the demo

| | macOS | Windows |
|---|---|---|
| Start | double-click `start-demo.command` | double-click `start-demo.bat` |
| Stop | double-click `stop-demo.command` | double-click `stop-demo.bat` |
| Start over with fresh data | double-click `reset-demo.command` | double-click `reset-demo.bat` |

The start file checks that Docker is running, downloads the newest version, starts the three applications and opens them in your browser.
The first start takes a few minutes (download); later starts take one to two minutes.

| Application | Address | Sign-in |
|---|---|---|
| DuckClinic (vet) | http://localhost:8080/duck-clinic/ | none |
| DuckInsurance | http://localhost:8081/ | `admin` / `admin` (also `adjuster` / `adjuster`, `customer` / `customer`) |
| Duck Physical Therapy Clinic | http://localhost:8082/ | none |

## If something goes wrong

| What you see | What to do |
|---|---|
| macOS says the file "cannot be opened" or is from an "unidentified developer" | Right-click the file, choose **Open**, then **Open** again. Needed only once. |
| "Docker is not installed" or "Docker Desktop did not start" | Start Docker Desktop yourself and wait until it says it is running. Then double-click start again. |
| "Port 8080 is used by another program" | Close other development tools, or restart the computer. |
| "llm.env still contains PASTE-..." | Open `llm.env`, fill in the model name and the key, save, start again. |
| An agent answers with an error about the model, a key or a "rate limit" | The key is wrong or used up, or the model service is busy. Wait a minute or contact the demo maintainer. |
| Anything else | Send a screenshot of the black window to the demo maintainer. |
