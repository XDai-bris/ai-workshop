# BMI and systolic blood pressure: Mendelian randomization (simulated data)

**Question.** Causal effect of BMI on SBP, in mmHg per 1 kg/m2 higher BMI.

**Data.** 147 BMI instruments; 127 used after harmonisation (20 dropped for missing outcome data, allele mismatch or ambiguous palindromic strand; see `results/harmonisation_log.csv`).

**Results.** IVW (random effects): 2.00 (95% CI 2.00 to 2.00) mmHg per kg/m2. Weighted median: 2.00 (95% CI 1.98 to 2.02). MR-Egger: 2.00 (95% CI 2.00 to 2.00).

**Heterogeneity and pleiotropy.** Cochran's Q = 147.0 on 126 df (p = 0.097). MR-Egger intercept = 0.000 mmHg (95% CI -0.000 to 0.000).

**Caveats.** Results rest on the usual MR assumptions, which these checks cannot prove. Data are simulated; do not interpret as real findings.
