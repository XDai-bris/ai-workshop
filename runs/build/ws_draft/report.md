# BMI and systolic blood pressure: Mendelian randomization (simulated data)

**Question.** Causal effect of BMI on SBP, in mmHg per 1 kg/m2 higher BMI.

**Data.** 100 BMI instruments; 89 used. Dropped: 4 absent from the outcome GWAS, 3 with missing outcome data, 4 ambiguous palindromic variants (MAF > 0.42). Details: `results/harmonisation_log.csv`.

**Results (mmHg per kg/m2).**
- IVW (random effects): 1.59 (95% CI -0.03 to 3.21)
- Weighted median: 3.29 (95% CI 1.00 to 5.58)
- MR-Egger: 5.42 (95% CI 0.61 to 10.22)

All estimates are positive, but IVW is imprecise and its interval includes zero. The methods differ considerably, so the size of the effect is uncertain.

**Heterogeneity and pleiotropy.** Cochran's Q = 135.6 on 88 df (p = 0.00084): clear heterogeneity. MR-Egger intercept = -0.024 mmHg (95% CI -0.052 to 0.004): no clear directional pleiotropy, though the interval is wide.

**Caveats.** Results rest on MR assumptions these checks cannot prove. Data are simulated; do not interpret as real findings.
