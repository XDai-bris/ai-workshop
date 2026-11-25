# BMI and systolic blood pressure: Mendelian randomization (simulated data)

**Question.** Causal effect of BMI on SBP, in mmHg per 1 kg/m2 higher BMI.

**Data.** 515 BMI instruments; 480 used after harmonisation (35 dropped for missing outcome data, allele mismatch or ambiguous palindromic strand; see `results/harmonisation_log.csv`).

**Results.** IVW (random effects): 1.20 (95% CI 1.04 to 1.36) mmHg per kg/m2. Weighted median: 1.78 (95% CI 1.66 to 1.90). MR-Egger: 1.33 (95% CI 0.74 to 1.92).

**Heterogeneity and pleiotropy.** Cochran's Q = 2664.9 on 479 df (p = 3.9e-299). MR-Egger intercept = -0.002 mmHg (95% CI -0.010 to 0.006).

**Caveats.** Results rest on the usual MR assumptions, which these checks cannot prove. Data are simulated; do not interpret as real findings.
