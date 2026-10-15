# Rules for AI agents working in this repository

This is a training repository for the IEU AI-for-coding workshop. **All data are simulated.**
The person you are working with does not write code. They direct the work, review it and make the decisions.
Your job is to execute carefully and make your work easy for them to check.

## Running code

- Run R only as `conda run -n ieu-ai-workshop Rscript <file>`. This works on Windows and macOS without
  activating the environment.
- The environment has **base R only**. Use no add-on packages, even if some happen to be visible. **Never install anything** (no
  `install.packages()`, `pip`, `conda install`, or new dependencies).
- Write analysis code in `analysis/` and outputs in `results/`. Plots go to `results/figures/` as PNG, made with
  base R graphics (`png()` … `dev.off()`).
- Use relative paths built with `file.path()`. Stay inside this repository folder. Every file you create, including
  temporary and scratch files, goes inside it (scratch files in `analysis/scratch/`), never in a parent folder or
  the system temp folder. R's own internal session temp folder is fine.
- Do not edit `data/` or `colleague_pipeline/`, or the human-owned sections of `spec/spec.md`, unless the human asks.
- `WORKSHEET.md`, `cards/`, `notes/` and `checkpoints/` are the human's own materials. Do not read, use or edit them
  unless the human asks you to.
- If the human asks you to commit and git has no user name or email, set them for this repository only
  (`git config user.name "Workshop participant"`, `git config user.email "participant@example.invalid"`) and say so.

## Working with the human

- Follow `spec/spec.md`. If anything in it is ambiguous, missing or looks wrong, **ask**; do not decide silently.
- **Stop and wait for the human** at these checkpoints:
  1. After inspecting the data and before writing analysis code: summarise the files, columns, units and anything unusual.
  2. After running the benchmarks (control datasets) and before touching `data/main`: report pass/fail against
     the spec's acceptance criteria.
  3. Before changing any test, tolerance, benchmark, acceptance criterion or pre-specified decision rule.
- Report the **primary result exactly as the spec's decision rules define it**. If you think another choice is
  better, say so separately and clearly; never switch the primary result yourself.
- Your messages must agree with your files. Quote numbers from the files in `results/`, not from memory.
- Explain what you did in plain English, so a non-programmer can check it against the spec.

## Output formats

- `results/estimates.csv`: `dataset, method, estimate, se, ci_lower, ci_upper, n_snps, is_primary`
  (estimates in mmHg per 1 kg/m² BMI). One row per dataset and method; `is_primary` is TRUE for exactly one row,
  the primary method on `data/main`.
- `results/benchmarks.csv`: `dataset, method, true_value, estimate, ci_lower, ci_upper, pass`
- `results/report.md`: short plain-English report that cites the files above
