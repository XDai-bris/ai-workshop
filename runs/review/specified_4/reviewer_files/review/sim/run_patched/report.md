# BMI and systolic blood pressure: Mendelian randomization (simulated data)

**Question.** Causal effect of BMI on SBP, in mmHg per 1 kg/m2 higher BMI.

**Data.** 194 BMI instruments; 171 used after harmonisation (23 dropped for missing outcome data, allele mismatch or ambiguous palindromic strand; see `results/harmonisation_log.csv`).

**Results.** IVW (random effects): 2.02 (95% CI 1.95 to 2.08) mmHg per kg/m2. Weighted median: 2.00 (95% CI 1.91 to 2.09). MR-Egger: 2.01 (95% CI 1.76 to 2.26).

**Heterogeneity and pleiotropy.** Cochran's Q = 217.1 on 170 df (p = 0.0085). MR-Egger intercept = 0.000 mmHg (95% CI -0.003 to 0.003).

**Caveats.** Results rest on the usual MR assumptions, which these checks cannot prove. Data are simulated; do not interpret as real findings.
