Validation walkthrough: case files
==================================

All data are simulated. Nothing here describes real people, variants or GWAS.

Folders
  1_draft_project/        The project as the Stage 2 reviewers saw it: the plan, the data, the agent's
                          script, results and report. It contains both errors (E1 and E2).
                          Use it with Prompt A, Prompt B and Prompt 3.
  2_after_stage3/         The project after the first fix and the first known-answer test.
                          Use it with Prompt 4 (milestone review).
  3_final_project/        The project after Stages 4 and 5: both errors fixed, tests pass.
  prompts/                Every prompt on the page, verbatim.
  replies/                Every recorded reply, verbatim (final message of each session).
  git_logs/               Commit history of the project at the end of Stage 3 and at the end.

To try it: copy a project folder somewhere, open it in your coding agent (Claude Code, Codex, or
another), and paste a prompt. Your agent's reply will differ from ours; compare what it checks,
not how it is worded.

R: the projects use base R only. The prompts mention `conda run -n ieu-ai-workshop Rscript`; any R
installation works if you run `Rscript` directly.
