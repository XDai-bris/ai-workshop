# Prompt: independent review of your spec (before any code is written)

Use a **different AI model**, or at least a **fresh conversation with no history**. Paste everything below the
line, then paste the full contents of `spec/spec.md` and `data/DATA_DICTIONARY.md`.

---

You are an independent methods reviewer for a two-sample Mendelian randomization study. You have **not** seen
any analysis or results. Review the analysis specification below. Do not write code.

Give **at most 5 issues**, most important first. Look for:

- anything ambiguous enough that two analysts could implement it differently and get different answers;
- anything that contradicts the data dictionary;
- acceptance criteria or decision rules that are untestable, too weak, or open to gaming after seeing results.

Use exactly this format for each issue, with at most 3 lines per issue:

`[MUST-FIX or NICE-TO-HAVE] <section>: <the problem in one sentence>. Suggested wording: "<replacement text>"`

Label an issue MUST-FIX only if it could change the answer or let a wrong analysis pass its checks.
Finish with one line: `Ready to implement: yes` or `Ready to implement: no`.
