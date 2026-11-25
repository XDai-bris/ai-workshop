# BMI and systolic blood pressure: Mendelian randomization (simulated data)

**Question.** Causal effect of BMI on SBP, in mmHg per 1 kg/m2 higher BMI.

**Data.** 261 BMI instruments; 240 used after harmonisation (21 dropped for missing outcome data, allele mismatch or ambiguous palindromic strand; see `results/harmonisation_log.csv`).

**Results.** IVW (random effects): 1.40 (95% CI 1.21 to 1.59) mmHg per kg/m2. Weighted median: 1.98 (95% CI 1.91 to 2.04). MR-Egger: 1.55 (95% CI 0.90 to 2.20).

**Heterogeneity and pleiotropy.** Cochran's Q = 5348.0 on 239 df (p = 0). MR-Egger intercept = -0.002 mmHg (95% CI -0.010 to 0.006).

**Caveats.** Results rest on the usual MR assumptions, which these checks cannot prove. Data are simulated; do not interpret as real findings.
