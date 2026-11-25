# BMI and systolic blood pressure: Mendelian randomization (simulated data)

**Question.** Causal effect of BMI on SBP, in mmHg per 1 kg/m2 higher BMI.

**Data.** 283 BMI instruments; 272 used after harmonisation (11 dropped for missing outcome data, allele mismatch or ambiguous palindromic strand; see `results/harmonisation_log.csv`).

**Results.** IVW (random effects): 8.40 (95% CI 6.45 to 10.35) mmHg per kg/m2. Weighted median: 16.86 (95% CI 16.21 to 17.51). MR-Egger: 4.65 (95% CI 0.88 to 8.41).

**Heterogeneity and pleiotropy.** Cochran's Q = 10509.7 on 271 df (p = 0). MR-Egger intercept = 0.050 mmHg (95% CI 0.007 to 0.093).

**Caveats.** Results rest on the usual MR assumptions, which these checks cannot prove. Data are simulated; do not interpret as real findings.
