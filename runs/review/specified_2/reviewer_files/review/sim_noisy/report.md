# BMI and systolic blood pressure: Mendelian randomization (simulated data)

**Question.** Causal effect of BMI on SBP, in mmHg per 1 kg/m2 higher BMI.

**Data.** 147 BMI instruments; 127 used after harmonisation (20 dropped for missing outcome data, allele mismatch or ambiguous palindromic strand; see `results/harmonisation_log.csv`).

**Results.** IVW (random effects): 1.39 (95% CI 0.83 to 1.94) mmHg per kg/m2. Weighted median: 1.51 (95% CI 0.77 to 2.25). MR-Egger: 2.59 (95% CI 0.10 to 5.08).

**Heterogeneity and pleiotropy.** Cochran's Q = 168.2 on 126 df (p = 0.0071). MR-Egger intercept = -0.013 mmHg (95% CI -0.039 to 0.013).

**Caveats.** Results rest on the usual MR assumptions, which these checks cannot prove. Data are simulated; do not interpret as real findings.
