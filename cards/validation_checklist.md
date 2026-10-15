# Card 2: Validation checklist for AI-built analyses (take home)

Use it for any analysis an AI builds for you, not only MR. Work through it **in order**: most items only count if
you do them **before** you see results.

## Before any code: pre-register

- [ ] **A known-answer benchmark.** Data where you know the answer (simulated, or a trusted published result), and a
      pass rule written down.
- [ ] **A null.** A case where the right answer is "no effect". A pipeline that has only seen real effects may find
      effects everywhere.
- [ ] **Decision rules.** Which result is primary, and what happens when a benchmark fails. **Every check must be able
      to change a decision**; a check whose result changes nothing is decoration.
- [ ] **An independent review of the spec.** A different model, or a fresh chat that has seen no results. You triage
      what it finds.
- [ ] **Commit the spec.** A timestamp you can point to later.

## While it runs: checkpoints

- [ ] **Predict, then look.** Write down what you expect before each result. A surprise is information.
- [ ] **Check the files, not the chat.** Numbers in the AI's message must match its output files.
- [ ] **You approve every change** to a test, tolerance, benchmark or rule. Loosening a test until it passes fixes
      nothing.

## After: before you believe it

- [ ] **Tests are not validation.** Tests written with the code (by a person or an AI) share the author's blind spots.
      Ask what they do not test.
- [ ] **Run the benchmark on the final code, unchanged.** The same code and settings as the real analysis.
- [ ] **Look at a plot.** Units, direction, outliers, impossible values.
- [ ] **Explain-back.** Can the AI explain each step in plain English, and does its story match the spec?
- [ ] **Would another reasonable analysis agree?** A second model, or a room of analysts, landing on the same answer
      is evidence; a wide spread is a warning.
- [ ] **Label every deviation.** Anything decided after seeing results is exploratory, and the report says so.

## Strong questions to ask your AI

| Instead of… | Ask… |
|---|---|
| "Is this correct?" / "Do the tests pass?" | "Run it, unchanged, on data where we know the answer. Quote the result from the output file." |
| "Looks good?" | "What would make this result wrong, and how would we detect it?" |
| "Summarise what you did." | "List every file you created or changed, and every decision you made that the spec did not specify." |
| "Fix it." | "Explain why it fails before changing anything. Do not change any test or tolerance." |
| "Which method is best?" (after results) | Decide before results, in the spec. |
