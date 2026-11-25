# BMI and systolic blood pressure: Mendelian randomization (simulated data)

**Question.** Causal effect of BMI on SBP, in mmHg per 1 kg/m2 higher BMI.

**Data.** 147 BMI instruments; 127 used after harmonisation (20 dropped for missing outcome data, allele mismatch or ambiguous palindromic strand; see `results/harmonisation_log.csv`).

**Results.** IVW (random effects): 1.79 (95% CI 1.27 to 2.31) mmHg per kg/m2. Weighted median: 1.58 (95% CI 0.86 to 2.31). MR-Egger: 0.35 (95% CI -1.97 to 2.67).

**Heterogeneity and pleiotropy.** Cochran's Q = 147.0 on 126 df (p = 0.097). MR-Egger intercept = 0.016 mmHg (95% CI -0.009 to 0.040).

**Caveats.** Results rest on the usual MR assumptions, which these checks cannot prove. Data are simulated; do not interpret as real findings.
