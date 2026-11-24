# Duck agents demo: notes for the maintainer

## Layout

The demo lives in its own folder (best: its own small repository, for example `duck-agents-demo`). The three application repositories stay as they are:
each keeps its own compose file and still runs on its own. The only addition to each application repository is one new file,
`.github/workflows/publish-image.yml` (in `add-to-each-app-repo/` of the handover zip), which builds and publishes that application's image.
It changes no existing file, so the temporary `salesdemo` branch merges back into `main` cleanly; you can also leave the workflow out of `main`.

```
duck-agents-demo/            <- this folder, given to sales (zip or git clone)
  compose.yaml               all three applications, one shared model configuration
  compose.build.yaml         maintainer only: build from the source folders instead of pulling
  .env                       image location (DEMO_IMAGE_PREFIX), no secrets, set once by you
  llm.env.example            model template; the start script copies it to llm.env
  start/stop/reset-demo.command   macOS
  start/stop/reset-demo.bat       Windows
  start/stop/reset-demo.sh        Linux (keep them executable: git update-index --chmod=+x *.sh)
```

## One-time setup

1. **Merge** the latest salesdemo code (duckinsurance version 7, duck-clinic version 5 or newer) into the `salesdemo` branch of each application repository, plus `publish-image.yml`.
2. **Publish the images.** Pushing to `salesdemo` runs the workflow and publishes `ghcr.io/<owner>/duck-clinic`, `duckinsurance` and
   `duckphysicaltherapyclinic` with the tag `salesdemo`, for Intel and Apple Silicon. The Apple Silicon part is built under emulation and can take
   15 to 30 minutes per image the first time [estimate]; later builds use the cache.
3. **Make the images reachable.** GitHub Container Registry packages are private by default. Either set each package to public
   (GitHub > your profile or organisation > Packages > package > Package settings > Change visibility), or every laptop has to run
   `docker login ghcr.io` with a token that can read packages. Public is simpler; the images contain no keys, but they contain the demo's code.
   If the repositories are private and must stay so, keep the packages private and plan the login.
4. **Set `.env`:** `DEMO_IMAGE_PREFIX=ghcr.io/<owner>`. The start, stop and reset scripts lower-case it (image names must be lower case, GitHub names often are not). If you run `docker compose` by hand, write it in lower case yourself.
5. **Test** on a clean Mac and a clean Windows laptop (and a Linux machine if anyone uses one), ideally by someone who has not seen the demo.

To try it without published images: put the three application folders next to this folder and run
`docker compose -f compose.yaml -f compose.build.yaml up -d --build` (no Java or Maven needed on the computer).

## How the applications reach each other

Inside the compose network they use the service names (`duck-clinic`, `duckinsurance`, `duckphysicaltherapyclinic`) instead of
`host.docker.internal`, so only the browser ports are published, on localhost only: 8080 (clinic), 8081 (insurer), 8082 (therapy).
The insurer's admin console (4848) is not published. The model is the only thing that may be on the host (`host.docker.internal`, for Ollama).

## Demo switches

`DUCK_ASSISTANT`, `DUCK_FRAUD_AGENT` and `DUCK_AGENTS_TAB` in `.env` set whether the three DuckInsurance switches start on or off (needs the insurance code of version 6). A restart of the demo goes back to these values.

## Fraud agent: patterns and investigation (duckinsurance version 7, duck-clinic version 5)

- What sales show is in `README.md` ("Showing the fraud agent"); the developer view is in the insurance repository (`README.md` section "Fraud agent", `DEMO.md`).
- The three prepared cases come from the seed data: `config/DataSeeder.java` in duckinsurance (claims and policies) and `startup/DataInitializer.java` in duck-clinic (the two Waddles visits). Both images must be at least these versions, or Waddles scores high because the clinic does not know the visits. To change a case, change both files and keep duck names and owners' last names identical, because the agent matches ducks by name and last name.
- Each check makes two model calls when the model asks for more evidence (about 1,200 input tokens each with the demo data [estimate from the prompt size]). On HTTP 429 the agent waits up to 30 seconds and retries once; if the second call still fails, the first answer counts. If a model plan is too small, set `DUCK_FRAUD_INVESTIGATE=off` in `.env` (one call per check, the signals stay).
- The details under the score are kept in memory only. After `stop-demo` and `start-demo` they are gone until Check is pressed again; the score and the reason stay as long as the container lives.
- Not tried yet with a real model: how well it chooses checks. Try it with the model sales will use before the first customer demo.

## Things to decide or know

- **API key on laptops.** `llm.env` on each laptop holds the real key. Anyone with the laptop can copy it, and usage cannot be told apart.
  For more than a few people, put a small gateway or one shared server in between, so the key never leaves your control (handover plan, step 4).
- **Docker Desktop licence.** Free for personal use, education, non-commercial open source and small businesses (fewer than 250 employees and
  less than 10 million USD annual revenue); larger companies need a paid subscription per user. Check with licensing before rolling out.
  Free alternatives that run this compose file: Rancher Desktop (choose the "dockerd (moby)" engine) and, with more set-up, Podman Desktop.
  The start scripts look for Docker Desktop; with an alternative, start it first and the scripts work as long as the `docker` command is there.
- **Rate limits.** Free tiers of model services are small (Groq free: 7,000 input tokens per minute; one Assistant round is about 2,650).
  Use a paid tier for demos.
- **Data.** The clinic and the insurer reset their data at every start, because `stop-demo` removes the containers. After a computer restart, Docker restarts the old containers (`restart: unless-stopped`) with their data; from duckinsurance version 7 the insurer no longer seeds its demo data a second time in that case. The therapy clinic keeps bookings in the volume `clinic-data`
  until `reset-demo` (`docker compose down -v`).
- **Updates.** The start script runs `docker compose pull`, so a push to `salesdemo` reaches the laptops at their next start.
