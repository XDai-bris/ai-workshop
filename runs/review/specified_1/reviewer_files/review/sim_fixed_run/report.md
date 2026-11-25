# BMI and systolic blood pressure: Mendelian randomization (simulated data)

**Question.** Causal effect of BMI on SBP, in mmHg per 1 kg/m2 higher BMI.

**Data.** 261 BMI instruments; 240 used after harmonisation (21 dropped for missing outcome data, allele mismatch or ambiguous palindromic strand; see `results/harmonisation_log.csv`).

**Results.** IVW (random effects): 2.02 (95% CI 1.98 to 2.06) mmHg per kg/m2. Weighted median: 2.03 (95% CI 1.97 to 2.09). MR-Egger: 1.90 (95% CI 1.77 to 2.04).

**Heterogeneity and pleiotropy.** Cochran's Q = 246.3 on 239 df (p = 0.36). MR-Egger intercept = 0.002 mmHg (95% CI -0.000 to 0.003).

**Caveats.** Results rest on the usual MR assumptions, which these checks cannot prove. Data are simulated; do not interpret as real findings.
