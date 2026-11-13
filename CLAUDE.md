# move-reminder

Десктопное приложение для Windows, которое раз в час напоминает встать и подвигаться, а ещё поесть, потренироваться и позаниматься теорией на права

The full spec is `docs/SPEC.md`. Read the sections your task touches before planning. `docs/INDEX.md` lists every document and when to read it.

## Current state

The process level, the merge protection mode, the template version and whether low and normal risk PRs may merge without the owner are in `.claude/pitwall.json`; why this level is in `docs/IDEA.md`. The current epic and its status are in `docs/EPICS.md`. This project is built with pitwall: `/pitwall:continue` picks up the next epic.

## Commands

E0 fills this section in. Never list a command here that has not been run successfully.

- All checks, as CI runs them: `scripts/gate --full`
- Inner loop: `scripts/gate --fast`
- Changed packages only: `scripts/gate --changed`
- The release build, which `/pitwall:release` runs: `scripts/build <version>`, printing an `ARTIFACT: <path>` line per thing it built
- Once in a new clone, so that `scripts/gate --fast` runs before every commit: `git config core.hooksPath .githooks`

## Architecture boundaries

From `docs/STACK.md` (Folder structure and module boundaries) and ADR-0003. Every boundary names the tool that enforces it.

- `src/MoveReminder.Core` holds the schedule, the reminder model and the settings file. It targets plain `net10.0`, not `net10.0-windows`, so it cannot use WinForms or WinRT types. Enforced by the compiler through the target framework in its `.csproj`.
- `src/MoveReminder.App` (tray, settings window, notifications, OS events, autostart) references Core. Core never references App. Enforced by MSBuild project references: a reference back from Core would make a cycle and the build fails.
- Core reads time only through `TimeProvider`, never `DateTime.Now`, `DateTime.UtcNow` or `DateTimeOffset.Now`. Enforced by BannedApiAnalyzers (`BannedSymbols.txt`), with warnings as errors.
- The app never goes to the network (docs/DISCOVERY.md: Personal data): `System.Net.Http` and `System.Net.Sockets` types are banned in both projects. Enforced by BannedApiAnalyzers.
- Tests of Core run without Windows UI on `FakeTimeProvider`. Enforced by `tests/MoveReminder.Core.Tests` referencing Core only, never App.

## Definition of done

A task is done when all of these hold:

- `scripts/gate --full` passes;
- every new module has tests, and every acceptance criterion has a test or a QA scenario;
- unit tests never touch the network;
- `docs/SPEC.md` or the README is updated if behaviour or architecture changed;
- a non-obvious decision has an ADR in `docs/adr/`;
- after an epic merges, `/pitwall:continue` records it in `docs/JOURNAL.md`, with before and after numbers where they exist.

## How to work

- Read `docs/LESSONS.md` before writing code.
- One epic, one branch `epic/E<n>-<slug>`, one PR; a bug fix goes on `fix/BUG-<n>`. Never push to `main`. Until the plan is merged, stages 1 to 5 commit on `plan/initial`.
- A decision that belongs to the owner is asked one question at a time, with the options compared.
- Check package versions in the registry, never from memory. Model IDs, prices and API limits live only in the config that `docs/STACK.md` names.
- Small conventional commits, each green on its own: `.githooks/pre-commit` runs `scripts/gate --fast` before every commit and refuses a red one. A commit of nothing but Markdown under `docs/` and `.claude/pitwall.json` passes it, and so does any commit on a `spike/*` branch.

## Never

- Read or print `.env*` files, or commit secrets.
- Set the `ai-review` status outside the review flow.
- Merge a PR whose `gate` or `ai-review` check is not green.
- Weaken a check, a hook or a test to make it pass. Fix the cause.
- Skip the gate before every commit: no `git commit --no-verify`, and `core.hooksPath` stays `.githooks`.
