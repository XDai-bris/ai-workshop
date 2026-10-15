# Card 1: Reading MR results (no MR background needed)

Please read this before the session (5 minutes). Keep it open during step 3.

## The question and the number

Does higher BMI raise systolic blood pressure (SBP)? The analysis answers with **one number**: the change in SBP,
in mmHg, per 1 kg/m² higher BMI. **0 means no effect.** All data here are simulated.

## How MR gets that number

Each genetic variant is a small natural experiment. It shifts BMI a little (x) and, if BMI causes SBP, it shifts
SBP in proportion (y). Across many variants, **y ≈ effect × x**, so the estimate is a **slope**.

The catch: a variant can also affect SBP through some other route ("pleiotropy"). Such variants sit off the line
and can drag the slope.

## Three methods: same data, different assumptions

| Method | In one line | Trustworthy when… | Weak spot |
|---|---|---|---|
| **IVW** (inverse-variance weighted) | The weighted average slope, through zero | **every** variant affects SBP only through BMI, or the side-routes cancel out | A minority of variants with side-routes in one direction pulls it off |
| **Weighted median** | The middle slope, weighting stronger variants more | **at least half** the weight comes from valid variants | Less precise than IVW |
| **MR-Egger** | A slope with an intercept, which absorbs a one-directional side-route | the side-routes are unrelated to how strongly each variant affects BMI | Much less precise: wide CIs |

If the three methods disagree, at least one assumption is broken. That is a finding, not noise.

## Reading a benchmark row (`results/benchmarks.csv`)

```
dataset,          method, true_value, estimate, ci_lower, ci_upper, pass
control_positive, IVW,    0.30,       0.27,     0.21,     0.33,     TRUE      (made-up example)
```

The 95% CI runs from 0.21 to 0.33. It includes the true value 0.30, so the method passes this control.

- **Positive control** (truth +0.30): can the pipeline find an effect that is really there?
- **Negative control** (truth 0): does the pipeline invent an effect that is not there?
- A method that fails either control has **not earned your trust on `data/main`**, whatever its tests say.

## Reading the scatter plot (`results/figures/scatter.png`)

- **Each dot is a variant:** x = its effect on BMI, y = its effect on SBP. Bars, if shown, are uncertainty.
- **Each line is a method; its slope is the estimate.** The IVW line goes through zero; the MR-Egger line need not.
- **Look for:**
  - dots far from the lines (possible side-routes);
  - lines that clearly disagree;
  - dots at impossible values such as −9 or +9 (a missing-value code read as data);
  - an axis stretched by one or two extreme dots, which makes everything else look flat.

## Red flags, in plain words

- A control's CI **excludes** its known answer.
- The numbers in the AI's message differ from the numbers in the files.
- Many of the 100 variants are dropped without a stated reason (a handful is normal: missing, absent, ambiguous).
- The primary method was chosen **after** seeing results.

Stuck on MR itself? Ask Gib: he leads the team behind the TwoSampleMR software.
