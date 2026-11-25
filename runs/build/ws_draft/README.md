# BMI -> systolic blood pressure: two-sample MR (simulated data)

Implements `analysis_plan.md` in base R. Data dictionary: `data/DATA_DICTIONARY.md`.

## Rerun
From this folder:

    conda run -n ieu-ai-workshop Rscript analysis/mr_analysis.R data/main

(The dataset folder argument is optional; default is `data/main`.) Outputs:
`results/estimates.csv`, `results/harmonisation_log.csv`, `results/figures/scatter.png`.
The script also regenerates a basic `report.md`, overwriting the hand-edited version; the
edited report is the one for the group, so keep a copy before rerunning.

## Headline result
89 of 100 instruments used. IVW estimate: **1.59 mmHg SBP per 1 kg/m2 BMI (95% CI -0.03 to 3.21)**.
Weighted median 3.29 (1.00 to 5.58); MR-Egger 5.42 (0.61 to 10.22), intercept -0.024 (-0.052 to 0.004).
Cochran's Q = 135.6 (df 88, p = 0.00084), so there is notable heterogeneity. The direction is positive in all methods, but
the primary IVW interval includes zero and the methods disagree on magnitude. Data are simulated.
