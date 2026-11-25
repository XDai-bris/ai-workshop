# Recorded agent runs

Every reply on the page comes from one of these runs, recorded on 24 November 2026. Each run is a prompt, the full
transcript of the session, and what the agent left in its copy of the project.

## How the runs were made

[`run_agent.sh`](run_agent.sh) runs one prompt in Claude Code, headless:

- model `claude-sonnet-5-5`, and a fresh session for every prompt (`--no-session-persistence`);
- the user's own settings, memory and MCP servers excluded (`--setting-sources project --strict-mcp-config`);
- sandboxed to the project folder, with file edits allowed and a fixed allowlist of shell commands;
- each run in its own copy of the project, with base R from the conda environment.

Usage: `run_agent.sh <project_folder> <prompt_file> <transcript.jsonl>`. Set `CONDA_ENV_BIN` if your
`ieu-ai-workshop` environment is not under `~/miniforge3/envs/`.

Transcripts are Claude Code `stream-json`, one event per line; the final reply is the `result` event.
`python3 extract.py <transcript.jsonl>` prints the tool calls and the final reply. The transcripts were cleaned before
publishing: local paths are replaced by placeholders such as `<runs>`, `<conda-env>` and `~`, and the local plugin and
skill lists and session ids were removed from each session's first event. Nothing else was changed.

## Runs, in page order

| Page | Folder | Prompt | Transcript | What else is here |
|---|---|---|---|---|
| Stage 1, Prompt 1: build | `build/` | `prompt1.txt` | `turn1.jsonl` | `planted_E2.diff`: the one line we changed after this turn |
| Stage 1, Prompt 2: run and report | `build/` | `prompt2.txt` | `turn2.jsonl` | `ws_draft/`: the draft project with both errors. `ws_review_base/`: the same draft as the reviewers got it (its `AGENTS.md` adds a scratch-folder note) |
| Stage 2, Prompt A: vague review (×5) | `review/vague_1` … `vague_5` | `review/vague.txt` | `review.jsonl` | `reviewer_files/`: files the reviewer created or changed in its copy |
| Stage 2, Prompt B: specified review (×5) | `review/specified_1` … `specified_5` | `review/specified.txt` | `review.jsonl` | `reviewer_files/`, including each reviewer's known-answer simulation |
| Stage 3, Prompt 3: fix, test, commit | `fix/` | `prompt.txt` | `turn.jsonl` | `ws/`: the project after commit `ad7be41`. `gitlog.txt` |
| Stage 4, Prompt 4: milestone review (Claude ×3) | `milestone/claude_1` … `claude_3` | `milestone_prompt.txt` | `review.jsonl` | `reviewer_files/` |
| Stage 4, Prompt 5: verify, then fix | `fix2/` | `prompt.txt` | `turn.jsonl` | |
| Stage 4, Prompt 6: the researcher's decision | `fix2/` | `prompt2.txt` | `turn2.jsonl` | `handworked.txt`: the hand-worked example added to the test |
| Stage 4: our check of the failing MR-Egger test | `checks/` | | | `egger_dilution.R` |
| Stage 5, Prompt 7: close-out review | `closeout/` | `prompt.txt` | `review.jsonl` | |
| Stage 5, Prompt 8: close-out changes | `cleanup/` | `prompt.txt` | `turn.jsonl` | `ws/`: the final project. `gitlog.txt`. `final_project_history.bundle`: all four commits (`git clone final_project_history.bundle final_project`) |

Also here:

- [`00_preregistration.md`](00_preregistration.md): how the ten Stage 2 reviews were scored, written before any of
  them ran.
- `case/`: the data rows shown in Stage 1.
- `archive/review_batch_blocked/`: a first batch of ten reviews, in which the sandbox blocked some commands. It showed
  the same pattern (every reviewer found E2, one in ten found E1). Transcripts and prompts only.
- `archive/first_case_design/`: drafting runs from our first version of the case, whose project folder documented a
  dataset with a known answer. In two of the three drafting runs the agent ran it without being asked, which is why the version on the page has none.
  Transcripts and prompts only.
