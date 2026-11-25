# BMI and systolic blood pressure: Mendelian randomization (simulated data)

**Question.** Causal effect of BMI on SBP, in mmHg per 1 kg/m2 higher BMI.

**Data.** 283 BMI instruments; 273 used after harmonisation (10 dropped for missing outcome data, allele mismatch or ambiguous palindromic strand; see `results/harmonisation_log.csv`).

**Results.** IVW (random effects): 8.36 (95% CI 6.42 to 10.31) mmHg per kg/m2. Weighted median: 16.86 (95% CI 16.22 to 17.49). MR-Egger: 4.68 (95% CI 0.91 to 8.44).

**Heterogeneity and pleiotropy.** Cochran's Q = 10541.7 on 272 df (p = 0). MR-Egger intercept = 0.049 mmHg (95% CI 0.006 to 0.092).

**Caveats.** Results rest on the usual MR assumptions, which these checks cannot prove. Data are simulated; do not interpret as real findings.
