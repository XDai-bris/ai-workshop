# BMI and systolic blood pressure: Mendelian randomization (simulated data)

**Question.** Causal effect of BMI on SBP, in mmHg per 1 kg/m2 higher BMI.

**Data.** 100 BMI instruments; 89 used after harmonisation (11 dropped for missing outcome data, allele mismatch or ambiguous palindromic strand; see `results/harmonisation_log.csv`).

**Results.** IVW (random effects): 1.59 (95% CI -0.03 to 3.21) mmHg per kg/m2. Weighted median: 3.29 (95% CI 1.00 to 5.58). MR-Egger: 5.42 (95% CI 0.61 to 10.22).

**Heterogeneity and pleiotropy.** Cochran's Q = 135.6 on 88 df (p = 0.00084). MR-Egger intercept = -0.024 mmHg (95% CI -0.052 to 0.004).

**Caveats.** Results rest on the usual MR assumptions, which these checks cannot prove. Data are simulated; do not interpret as real findings.
