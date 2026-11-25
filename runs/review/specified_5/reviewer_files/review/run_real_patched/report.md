# BMI and systolic blood pressure: Mendelian randomization (simulated data)

**Question.** Causal effect of BMI on SBP, in mmHg per 1 kg/m2 higher BMI.

**Data.** 100 BMI instruments; 89 used after harmonisation (11 dropped for missing outcome data, allele mismatch or ambiguous palindromic strand; see `results/harmonisation_log.csv`).

**Results.** IVW (random effects): 4.77 (95% CI 3.45 to 6.09) mmHg per kg/m2. Weighted median: 5.20 (95% CI 3.15 to 7.26). MR-Egger: 7.33 (95% CI 3.39 to 11.26).

**Heterogeneity and pleiotropy.** Cochran's Q = 89.9 on 88 df (p = 0.42). MR-Egger intercept = -0.016 mmHg (95% CI -0.039 to 0.007).

**Caveats.** Results rest on the usual MR assumptions, which these checks cannot prove. Data are simulated; do not interpret as real findings.
