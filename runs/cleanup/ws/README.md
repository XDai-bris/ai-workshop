# BMI -> systolic blood pressure: two-sample MR (simulated data)

Implements `analysis_plan.md` in base R. Data dictionary: `data/DATA_DICTIONARY.md`.

## Rerun
From this folder:

    conda run -n ieu-ai-workshop Rscript analysis/mr_analysis.R data/main

(The dataset folder argument is optional; default is `data/main`.) Outputs:
`results/estimates.csv`, `results/harmonisation_log.csv`, `results/heterogeneity.csv`, `results/figures/scatter.png`.
The script also writes a basic generated report to `results/report_auto.md`. It never touches the
hand-edited `report.md`, which is the one for the group.

## Test
    conda run -n ieu-ai-workshop Rscript tests/test_known_answer.R

Simulates exposure and outcome files covering every allele situation (aligned, swapped, complemented,
complemented and swapped, palindromic on same/opposite strand, plus dropped cases) with a true effect of
2 mmHg per kg/m2 (plus a four-variant example with hand-calculated answers), runs the script and checks the log labels and that IVW, MR-Egger and weighted median recover it.

## Headline result
89 of 100 instruments used. IVW estimate: **0.21 mmHg SBP per 1 kg/m2 BMI (95% CI 0.15 to 0.26)**.
Weighted median 0.23 (0.14 to 0.32); MR-Egger 0.32 (0.15 to 0.49), intercept -0.016 (-0.039 to 0.007).
Cochran's Q = 89.9 (df 88, p = 0.42), so there is no evidence of heterogeneity. The direction is positive in all methods
and all intervals exclude zero. Data are simulated.

## Correction history
Two errors in earlier versions; both estimates quoted below were wrong. The correct IVW estimate is 0.21.

1. Outcome effects were not negated for the 27 variants whose outcome alleles are the complement of the exposure
   alleles with order swapped (now labelled "strand: complemented and allele order swapped, flipped"). Those
   variants contributed with the wrong sign, which pulled the IVW estimate away from the value it had once they
   were handled correctly: 1.59 before this fix, 4.77 after it (both still on the wrong scale, see 2).
2. Exposure BETA and SE (per SD of BMI) were divided by 4.8 instead of multiplied, so every causal estimate was
   4.8^2 = about 23 times too large (4.77 / 23 = 0.21). The known-answer test had the same error in its data
   generation, so it passed anyway; it now also includes a hand-worked example (expected IVW 0.5, SE 1/12).

## Deviations from the plan
- The plan drops palindromic variants with MAF above 0.42 without saying which file. The code checks both the
  exposure EAF and the outcome frequency and drops the variant if either exceeds 0.42. In `data/main` the outcome
  check drops nothing extra: all 4 dropped palindromic variants already have exposure MAF above 0.42
  (0.439 to 0.495), so the exposure check alone would give the same 89 instruments.
