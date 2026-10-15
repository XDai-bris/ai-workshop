# Analysis specification (reference checkpoint v2: after the Practical 2 spec steps)

> **Catch-up file for Group R.** If your reviewed sections 6–8 are not ready when implementation starts, copy this
> file to `spec/spec.md`. It is the PI's draft after an independent review.

## 1. Research question

Does higher BMI causally raise systolic blood pressure (SBP)? Two-sample Mendelian randomization using the
simulated summary statistics in `data/`.

## 2. Data

- `data/main/exposure_bmi_gwas.tsv`: 100 independent BMI instruments (P < 5×10⁻⁸). `BETA`/`SE` are per copy of
  `EFFECT_ALLELE`, in **SD units of BMI (1 SD = 4.8 kg/m²)**. The DNA strand is not guaranteed.
- `data/main/outcome_sbp_gwas.tsv`: the same variants looked up in an SBP GWAS (mmHg). **`beta` and `freq` refer
  to `A2`.** Forward strand. **Missing values are coded `-9`.** Some instruments are absent.
- Control datasets with known answers, in the same formats: `data/control_positive/` (true effect +0.30) and
  `data/control_negative/` (true effect 0).

## 3. Estimand

The causal effect of BMI on SBP, in **mmHg per 1 kg/m² higher BMI**.

## 4. Methods

Data preparation:
1. Treat `-9` as missing. Drop variants with missing outcome data or absent from the outcome file.
2. Align every variant to the exposure effect allele, using both alleles and allowing for strand differences
   (complementary bases). For palindromic variants (A/T, C/G), infer the strand from allele frequency, and drop
   them if the minor allele frequency (from the exposure `EAF`) is above 0.42.
3. Convert exposure effects from SD units to kg/m² (multiply `BETA` and `SE` by 4.8).

Estimation (all 95% CIs = estimate ± 1.96 × SE):
- **Inverse-variance weighted (IVW):** weighted regression of the SNP–outcome on the SNP–exposure effects through
  the origin, with weights 1/SE(outcome)². Use multiplicative random effects: the SE is scaled up when the variants
  disagree more than chance would explain, and never scaled down.
- **MR-Egger:** first orient each variant so that its BMI effect is positive. Then fit the same weighted regression
  with an intercept, using the same SE rule. Report the slope (the causal estimate) and the intercept.
- **Weighted median:** first-order weights. SE from 1,000 parametric bootstrap draws with a fixed, recorded seed.

Diagnostics: Cochran's Q, MR-Egger intercept, scatter plot, funnel plot.

## 5. Outputs

- `results/estimates.csv`, `results/report.md` (formats in `AGENTS.md`)
- `results/figures/scatter.png`: SNP–exposure vs SNP–outcome effects, with a fitted line for each method

## 6. Validation and benchmarks (Practical 2)

Before **any** analysis of `data/main`, run the complete pipeline, unchanged, on both control datasets.

- **Positive control** (true effect +0.30): a method passes if its 95% CI includes 0.30.
- **Negative control** (true effect 0): a method passes if its 95% CI includes 0.
- The pipeline may proceed to `data/main` only if **at least one method passes both controls**. If none does,
  stop and report to the human; do not analyse `data/main`.
- Data preparation must be identical for every dataset. Record the outcome in `results/benchmarks.csv`.

## 7. Pre-specified decision rules (Practical 2)

Written before seeing any results.

1. The primary method is **IVW** if it passes both controls.
2. Otherwise it is the **weighted median** if that passes both controls; otherwise **MR-Egger** if that passes both;
   otherwise there is no primary result (stop).
3. All three methods are always reported. Exactly one row has `is_primary = TRUE`.
4. No variants are removed after looking at the results. Any post-hoc analysis (e.g. outlier removal) must be
   labelled *exploratory* and is never the primary result.

## 8. Human checkpoints (Practical 2)

The three checkpoints in `AGENTS.md` (after data inspection; after the benchmarks and before `data/main`; before
changing any test, criterion or rule), plus: **show me the scatter plot before writing the report.**
