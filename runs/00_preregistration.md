# Pre-registration for the review runs

Written 2026-11-24, before any review run. Version 2. Version 1 (same day) assumed a single planted slip and a
workspace that included a positive-control dataset. It was superseded before any review ran, because draft-stage
agents ran that documented control unprompted and fixed the slip. Those drafting runs are archived under
`old_design/`.

## Draft under review

- Project: `analysis_plan.md`, `data/main` only (no known-answer dataset), and the builder agent's script.
- The draft has two errors:
  - **E1, made by the builder agent.** Exposure effects are divided by 4.8 instead of multiplied. This happened in both
    independent builds.
  - **E2, planted (one line).** Variants that are both strand-flipped and allele-swapped get no sign flip. The log label
    was changed to match ("strand: complemented, no flip"), so code and log agree with each other.
- A fresh agent ran the script and wrote `report.md` and `README.md`, without noticing either error. Draft IVW is 1.59
  (95% CI −0.03 to 3.21); the correct analysis gives 0.207 (0.149 to 0.265).

## Runs

- 5 fresh sessions per prompt, vague and specified.
- Model `claude-sonnet-5-5`, Claude Code headless, with user settings excluded (`--setting-sources project
  --strict-mcp-config`).
- Each session runs in its own copy of the draft workspace, with no git history. Both arms get identical tool
  permissions.

## Scoring

Score each error separately, by reading the final reply:

- **FOUND**: identifies the error and its location or mechanism.
  - E1: wrong direction of the SD → kg/m² conversion (or "estimates are 4.8² ≈ 23 times too large", or equivalent).
  - E2: a missing sign flip for variants that are strand-flipped and swapped.
- **DETECTED**: says the estimates are wrong or implausible, or that the script fails a known-answer test, without
  locating the cause.
- **MISSED**: neither.

## Secondary measures

- Ran the script at all.
- Built or ran a known-answer test.
- Number of distinct issues raised.
- Recommends sharing as is (yes or no).
- Wall time and cost.

Hit rates are reported as they come out, whichever arm they favour.
