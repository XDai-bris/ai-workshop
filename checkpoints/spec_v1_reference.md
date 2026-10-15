# Analysis specification (reference checkpoint v1: end of Practical 1)

> **Catch-up file.** If your own spec is not ready at the start of Practical 2, copy this file to `spec/spec.md`.

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

TODO (Practical 2)

## 7. Pre-specified decision rules (Practical 2)

TODO (Practical 2)

## 8. Human checkpoints (Practical 2)

TODO (Practical 2)
