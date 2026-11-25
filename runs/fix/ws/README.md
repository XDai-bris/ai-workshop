# BMI -> systolic blood pressure: two-sample MR (simulated data)

Implements `analysis_plan.md` in base R. Data dictionary: `data/DATA_DICTIONARY.md`.

## Rerun
From this folder:

    conda run -n ieu-ai-workshop Rscript analysis/mr_analysis.R data/main

(The dataset folder argument is optional; default is `data/main`.) Outputs:
`results/estimates.csv`, `results/harmonisation_log.csv`, `results/figures/scatter.png`.
The script also regenerates a basic `report.md`, overwriting the hand-edited version; the
edited report is the one for the group, so keep a copy before rerunning.

## Test
    conda run -n ieu-ai-workshop Rscript tests/test_known_answer.R

Simulates exposure and outcome files covering every allele situation (aligned, swapped, complemented,
complemented and swapped, palindromic on same/opposite strand, plus dropped cases) with a true effect of
2 mmHg per kg/m2, runs the script and checks the log labels and that IVW, MR-Egger and weighted median recover it.

## Headline result
89 of 100 instruments used. IVW estimate: **4.77 mmHg SBP per 1 kg/m2 BMI (95% CI 3.45 to 6.09)**.
Weighted median 5.20 (3.15 to 7.26); MR-Egger 7.33 (3.39 to 11.26), intercept -0.016 (-0.039 to 0.007).
Cochran's Q = 89.9 (df 88, p = 0.42), so there is no evidence of heterogeneity. The direction is positive in all methods
and all intervals exclude zero. Data are simulated.

Correction: an earlier version did not negate the outcome effect for variants whose outcome alleles are the
complement of the exposure alleles with order swapped (27 variants, now labelled
"strand: complemented and allele order swapped, flipped"). This had biased the IVW estimate towards zero (previously 1.59).
