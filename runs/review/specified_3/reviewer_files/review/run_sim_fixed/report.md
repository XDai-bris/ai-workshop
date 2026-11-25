# BMI and systolic blood pressure: Mendelian randomization (simulated data)

**Question.** Causal effect of BMI on SBP, in mmHg per 1 kg/m2 higher BMI.

**Data.** 283 BMI instruments; 272 used after harmonisation (11 dropped for missing outcome data, allele mismatch or ambiguous palindromic strand; see `results/harmonisation_log.csv`).

**Results.** IVW (random effects): 0.79 (95% CI 0.77 to 0.80) mmHg per kg/m2. Weighted median: 0.78 (95% CI 0.76 to 0.80). MR-Egger: 0.78 (95% CI 0.75 to 0.81).

**Heterogeneity and pleiotropy.** Cochran's Q = 321.7 on 271 df (p = 0.019). MR-Egger intercept = 0.004 mmHg (95% CI -0.004 to 0.011).

**Caveats.** Results rest on the usual MR assumptions, which these checks cannot prove. Data are simulated; do not interpret as real findings.
