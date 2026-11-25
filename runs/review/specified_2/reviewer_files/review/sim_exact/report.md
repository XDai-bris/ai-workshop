# BMI and systolic blood pressure: Mendelian randomization (simulated data)

**Question.** Causal effect of BMI on SBP, in mmHg per 1 kg/m2 higher BMI.

**Data.** 147 BMI instruments; 127 used after harmonisation (20 dropped for missing outcome data, allele mismatch or ambiguous palindromic strand; see `results/harmonisation_log.csv`).

**Results.** IVW (random effects): 1.16 (95% CI 0.88 to 1.45) mmHg per kg/m2. Weighted median: 2.00 (95% CI 1.97 to 2.02). MR-Egger: 1.62 (95% CI 0.34 to 2.90).

**Heterogeneity and pleiotropy.** Cochran's Q = 4416444431.6 on 126 df (p = 0). MR-Egger intercept = -0.005 mmHg (95% CI -0.018 to 0.009).

**Caveats.** Results rest on the usual MR assumptions, which these checks cannot prove. Data are simulated; do not interpret as real findings.
