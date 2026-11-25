# BMI and systolic blood pressure: Mendelian randomization (simulated data)

**Question.** Causal effect of BMI on SBP, in mmHg per 1 kg/m2 higher BMI.

**Data.** 100 BMI instruments; 89 used. Dropped: 4 absent from the outcome GWAS, 3 with missing outcome data, 4 ambiguous palindromic variants (MAF > 0.42). Details: `results/harmonisation_log.csv`. An earlier version mishandled variants whose outcome alleles were complemented and swapped (27 variants); this is corrected, which changed the results.

**Results (mmHg per kg/m2).**
- IVW (random effects): 4.77 (95% CI 3.45 to 6.09)
- Weighted median: 5.20 (95% CI 3.15 to 7.26)
- MR-Egger: 7.33 (95% CI 3.39 to 11.26)

All estimates are positive and all intervals exclude zero. MR-Egger is the least precise and its point estimate is the largest.

**Heterogeneity and pleiotropy.** Cochran's Q = 89.9 on 88 df (p = 0.42): no evidence of heterogeneity. MR-Egger intercept = -0.016 mmHg (95% CI -0.039 to 0.007): no clear directional pleiotropy.

**Caveats.** Results rest on MR assumptions these checks cannot prove. Data are simulated; do not interpret as real findings.
