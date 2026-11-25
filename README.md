# Validating an analysis written by an AI agent

A 45-minute worked example for the IEU AI-for-coding workshop (Practical 2: validation). An AI agent writes a
two-sample Mendelian randomization analysis on simulated data, and we validate it step by step. Every step shows the
prompt we sent and the reply the agent actually gave, so the room can follow without a laptop.

**View the page: <https://xdai-bris.github.io/ai-workshop/validation_walkthrough.html>**

Or download [`validation_walkthrough.html`](validation_walkthrough.html) and open it in any web browser; it is a single
file and works offline. (GitHub's file view shows the source, not the page.)

## The storyline

1. **The case.** An agent writes a two-sample MR analysis (BMI on systolic blood pressure). The draft has two errors:
   a unit error the agent made itself, and a harmonisation slip we planted.
2. **Review, vague or specified (the core).** Ten fresh reviews. The simple error was found every time, whatever we
   asked; the deep error, once. A specified review lays out its evidence, and the deep error is visible in that
   evidence to anyone who reads it.
3. **Every step:** check, fix, add a test, commit.
4. **Milestone:** a new reviewer with new questions, including a second model. The deep error was found in 4 of 5
   runs. Verify the finding by hand, then fix it.
5. **Close-out:** rerun from the README, trace every number to a file, read the documents against each other.
6. **Outlook:** write the checks first, then let agents run longer.

The page ends with five take-home messages and further reading.

## What is in this repository

| Path | What it holds |
|---|---|
| [`validation_walkthrough.html`](validation_walkthrough.html) | The page |
| [`case/`](case/) | The simulated MR case: simulation code, the project the agent starts from, and the simulation truth |
| [`runs/`](runs/) | Every agent run shown on the page: prompts, full transcripts, what the agents wrote, and the pre-registration for Stage 2 |
| [`page/`](page/) | The page sources. `build_page.py` rebuilds the HTML, byte for byte, from `runs/` |
| `environment.yml`, `setup/` | The conda environment (base R only) used for every run |

## Reproduce or extend

1. **Environment.** `conda env create -f environment.yml`, then
   `conda run -n ieu-ai-workshop Rscript setup/check_setup.R` should print `SETUP OK`.
2. **Regenerate the case.** `conda run -n ieu-ai-workshop Rscript case/generate_case.R` rewrites the data and truth
   files; `git diff` should show no change. `case/check_case.R` fits the correct pipeline and the planted bug.
3. **Try a prompt yourself.** Copy `case/project_template/` (or a project snapshot under `runs/`) to a new folder,
   open it in a coding agent, and paste a prompt from `runs/`. Your agent's replies will differ from ours; compare what
   it checks, not how it is worded.
4. **Rerun the recorded runs.** `runs/run_agent.sh` runs one prompt headless in Claude Code, with the settings we
   used. See [`runs/README.md`](runs/README.md).
5. **Change the page.** Edit the fragments in `page/`, then `python3 page/build_page.py validation_walkthrough.html`.
   See [`page/README.md`](page/README.md).

Continuous integration checks steps 1, 2 and 5 on every push: the environment installs on Windows and macOS, the case
regenerates identically, and the page rebuilds identically from `runs/`.

## Notes

- All data are simulated. They describe no real people, variants or GWAS.
- The transcripts were cleaned of local file paths and local tool settings. Nothing else was changed.
- The second-model reviews in Stage 4 were run by hand in the Codex desktop app. The page reports their findings;
  their logs are not part of this repository.
- The earlier hands-on version of this practical (October 2026) is kept at the git tag `hands-on-v3-2026-10`.
- Prepared by Xiaoyang Dai and Gibran Hemani for the MRC Integrative Epidemiology Unit AI-for-coding workshop,
  November 2026.
