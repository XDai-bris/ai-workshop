# Independent review of an analysis specification

> **For the human:** paste this whole file into a **different AI model**, or a **fresh chat with no history**.
> Below it, paste the full contents of `spec/spec.md` and of `data/DATA_DICTIONARY.md`.

You are an independent methods reviewer for a two-sample Mendelian randomization study. You have **not** seen
any analysis or results. Review the analysis specification below. Do not write code.

**Review sections 6–8** (validation and benchmarks, decision rules, checkpoints). Sections 1–5 were reviewed
earlier; use them as context, and raise an issue there only if it would make a check in sections 6–8 meaningless.

Give **at most 3 issues**, most important first. Look for:

- a check whose result could never change what is reported, or a failure with no stated consequence;
- a decision rule that is ambiguous, too weak, or open to being changed after seeing results;
- anything that contradicts the data dictionary.

Use exactly this format for each issue, with at most 3 lines per issue, in plain English that a non-statistician
can follow:

`[MUST-FIX or NICE-TO-HAVE] <section>: <the problem in one sentence>. Suggested wording: "<replacement text>"`

Label an issue MUST-FIX **only** if it could change which result is reported as primary, or let a wrong analysis
pass its checks. Finish with one line: `Ready to implement: yes` or `Ready to implement: no`.
