# BMI and systolic blood pressure: Mendelian randomization (simulated data)

**Question.** Causal effect of BMI on SBP, in mmHg per 1 kg/m2 higher BMI.

**Data.** 194 BMI instruments; 171 used after harmonisation (23 dropped for missing outcome data, allele mismatch or ambiguous palindromic strand; see `results/harmonisation_log.csv`).

**Results.** IVW (random effects): 1.20 (95% CI 0.95 to 1.45) mmHg per kg/m2. Weighted median: 1.87 (95% CI 1.76 to 1.98). MR-Egger: 0.77 (95% CI -0.18 to 1.73).

**Heterogeneity and pleiotropy.** Cochran's Q = 3252.9 on 170 df (p = 0). MR-Egger intercept = 0.005 mmHg (95% CI -0.005 to 0.015).

**Caveats.** Results rest on the usual MR assumptions, which these checks cannot prove. Data are simulated; do not interpret as real findings.
