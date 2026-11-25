# BMI and systolic blood pressure: Mendelian randomization (simulated data)

**Question.** Causal effect of BMI on SBP, in mmHg per 1 kg/m2 higher BMI.

**Data.** 515 BMI instruments; 480 used after harmonisation (35 dropped for missing outcome data, allele mismatch or ambiguous palindromic strand; see `results/harmonisation_log.csv`).

**Results.** IVW (random effects): 2.00 (95% CI 1.93 to 2.07) mmHg per kg/m2. Weighted median: 2.02 (95% CI 1.92 to 2.13). MR-Egger: 1.97 (95% CI 1.71 to 2.23).

**Heterogeneity and pleiotropy.** Cochran's Q = 505.3 on 479 df (p = 0.2). MR-Egger intercept = 0.000 mmHg (95% CI -0.003 to 0.004).

**Caveats.** Results rest on the usual MR assumptions, which these checks cannot prove. Data are simulated; do not interpret as real findings.
