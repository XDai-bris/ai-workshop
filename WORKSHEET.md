# Practical 2 worksheet: validating what your AI builds (11:45–12:45)

You direct your AI agent; you write **no code**. At each step you:

**📋 paste** a prompt → **🔮 predict** before you look → **🔍 check** the files, not the chat → **✅ decide**.

Write your predictions and decisions in [`notes/my_predictions.md`](notes/my_predictions.md) (or on paper)
**before** you see each result. Your AI is told not to touch that file.

## By 12:45 you will be able to

1. **Tell "tested" from "validated".** Check an AI-built analysis against a known answer without reading its code.
2. **Pre-register.** Fix benchmarks and decision rules *before* any result exists, and have the plan reviewed independently.
3. **Be the checker at checkpoints.** Predict, check the AI's claims against its files, then decide.

Keep [Card 1: Reading MR results](cards/reading_mr_results.md) open. [Card 2](cards/validation_checklist.md) is your take-home.

## Your group

Gib splits the room into **Group R** and **Group N**. Only step 2 differs. Write your group in your notes.

---

## Step 0 (11:45): ready?

- [ ] `spec/spec.md` exists and sections 1–5 are filled in. If not, ask your agent:
  `Copy checkpoints/spec_v1_reference.md to spec/spec.md.`
- [ ] Start a **new chat** with your agent, opened in this folder, and paste:

```text
Read AGENTS.md and follow it for this whole session. Reply "Ready" when you have read it.
```

## Step 1 (11:50–12:00): a colleague's AI-built pipeline

A colleague shares an analysis their AI built: "It's fully tested." Their README reports **0.30 mmHg per kg/m²**.

**1a. 📋 Ask the question most people ask:**

```text
A colleague shared the analysis in colleague_pipeline/ (see its README). Run its tests and tell me whether they pass.
```

🔍 How many tests passed? Did your agent do anything beyond what you asked?

**🔮 P1.** Would you put the colleague's 0.30 in a paper? And will the pipeline recover the **known** +0.30 on the
positive control? Write *yes* or *no* to each.

**1b. 📋 Now ask for evidence with a known answer:**

```text
Run the colleague's pipeline, unchanged, on data/control_positive, where the true effect is known to be +0.30.
Quote its estimate and 95% CI from the output file. Does the CI include 0.30?
```

🔍 Open `results/colleague_pipeline/control_positive/estimates.csv` yourself. Same numbers as in the chat?

**1c. 📋 Ask why, without letting it fix anything** (skip if your agent has already explained):

```text
The tests pass but the positive control fails. Without changing any code, explain in plain English why.
What do the tests not test?
```

✅ **Decide:** would you use the colleague's result?

> **Takeaway.** The question you ask decides the evidence you get. Tests written alongside the code check what its
> author thought of; a known answer checks what actually happens.

*Fast? Ask: `Show me results/colleague_pipeline/main/scatter.png after running the pipeline on data/main. What looks odd?`*

## Step 2 (12:00–12:12): pre-register your plan

Your PI has drafted sections 6–8 of your spec (validation, decision rules, checkpoints).

**2a. 📋 Paste the draft into your spec:**

```text
Replace the empty sections 6-8 of spec/spec.md with sections 6-8 of spec/draft_sections_6-8.md
(without the email header). Change nothing else.
```

**🔮 P2.** Read sections 6–7 of `spec/spec.md` yourself (2 minutes, with Card 1). Is anything missing or risky?
Which method do you expect to end up primary?

**2b. Your group's step:**

| Group R: independent review | Group N: no review |
|---|---|
| 1. Open a **different AI model**, or a **fresh chat with no history**. Not your working agent. | Re-read sections 6–8 yourself. |
| 2. Paste the whole of `prompts/spec_review.md`, then the contents of `spec/spec.md` and `data/DATA_DICTIONARY.md`. | Your agent may have raised concerns about the draft. **You decide:** change it now (ask your agent to), or keep the PI's text. Write down which, and why. |
| 3. **Triage:** for each MUST-FIX item, accept or reject it and write a one-line reason in your notes. Skip NICE-TO-HAVE items today. | Then go to 2c. |
| 4. Tell your working agent: `Update sections 6-8 of spec/spec.md with these accepted changes, using the suggested wording. Change nothing else:` and paste the accepted items. | |

**2c. 📋 Commit: this is your pre-registration timestamp.**

```text
Commit spec/spec.md with the message "Pre-register sections 6-8". Commit nothing else.
```

*Your agent can't commit (some tools block git)? Approve its request if it asks, or run the command it gives you
in a terminal.*

*Behind at 12:12? Group R: copy `checkpoints/spec_v2_reference.md` to `spec/spec.md`. Group N: do 2a only. Then commit.*

## Step 3 (12:12–12:32): your agent implements, you check

**3a. 📋 Start:**

```text
Implement the analysis exactly as specified in spec/spec.md. Follow AGENTS.md and stop at every checkpoint.
```

**Checkpoint 1: the data** (your agent stops after inspecting the files)

- 🔍 Compare its summary with `data/DATA_DICTIONARY.md`. Did it mention: the `-9` missing values; that outcome effects
  refer to `A2`; the SD-to-kg/m² conversion; the strand issue and palindromic variants; instruments absent from the
  outcome file? Ask about anything it missed.
- If it asks you questions, answer them (Card 1 helps), or accept its proposed defaults.
- **🔮 P3.** Which methods will pass **both** controls: IVW, weighted median, MR-Egger?
- ✅ Reply, e.g. `Approved. Continue to the benchmarks.`

**Checkpoint 2: the benchmarks** (it stops before touching `data/main`)

- 🔍 Open `results/benchmarks.csv` yourself. Do the numbers match the chat? For each row, does the CI include the true
  value? Compare with your P3.
- **🔮 P4.** Under the rules in section 7, which method will be primary? Roughly what do you expect for `data/main`?
- ✅ **Decide**, and write your decision in your notes:
  - keep the pre-registered rules: `Continue to data/main under section 7 as written.`; or
  - change a rule now. You have seen results, so say so: `I am changing rule __ to __ after seeing the benchmarks.
    Record this in the report as a deviation from the pre-registered plan, then continue.`

**Plot check** (spec section 8: it stops to show you the scatter plot)

- 🔍 Open `results/figures/scatter.png`. Use Card 1: dots far off the lines? Do the lines agree?
- ✅ `Approved. Write the report.`

**3b. 🔍 Final check, in the files:** in `results/estimates.csv`, exactly one row has `is_primary = TRUE`, and it is
the method your section 7 picks. `results/report.md` quotes the same numbers.

*Agent stuck or broken? Follow Gib's screen.*

## Step 4 (12:35): submit, then the truth

Submit through the link Gib shows: your group, P1, your primary method, estimate and 95% CI, whether you changed any
rule after seeing results, and how sure you are (0–100%) that your CI contains the true value.

Gib then reveals the true effect for `data/main` and plots the whole room.

## Step 5 (12:42): take home

Open [Card 2](cards/validation_checklist.md). Which item would have mattered most today? What would you add for the
13:30 session?
