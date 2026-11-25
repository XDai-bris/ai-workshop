# Notes for AI agents working on this repository

This repository holds a teaching page and everything needed to rebuild it. See `README.md`.

- `validation_walkthrough.html` is generated. Change the page by editing `page/*.html`, then run
  `python3 page/build_page.py validation_walkthrough.html` from the repository root.
- `runs/` is a record of real agent sessions. Do not edit transcripts, prompts or the projects inside them. A new run
  goes in a new folder, with its prompt and transcript.
- `case/project_template/` is what an agent analyses in the exercise. Never put answers, the truth or reviews in it.
  `case/truth/` must never be copied into an agent's working folder.
- Data are simulated. R is base R only, run as `conda run -n ieu-ai-workshop Rscript <file>`.
- After a change, check that the page rebuilds and that `conda run -n ieu-ai-workshop Rscript case/generate_case.R`
  leaves `git diff` empty.
