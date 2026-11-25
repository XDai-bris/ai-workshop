# Analysis plan: effect of BMI on systolic blood pressure

Two-sample Mendelian randomization with summary statistics. Written before any analysis. All data are simulated.

## Question

What is the causal effect of body mass index (BMI) on systolic blood pressure (SBP), in **mmHg per 1 kg/m² higher BMI**?

## Data

`data/main/exposure_bmi_gwas.tsv` (BMI instruments) and `data/main/outcome_sbp_gwas.tsv` (the same variants looked up
in an SBP GWAS). Column definitions, units and coding are in `data/DATA_DICTIONARY.md`.

## Steps

1. **Read and clean.** Treat the outcome missing-value code as missing. Drop instruments with no usable outcome data.
2. **Harmonise** every variant so that the exposure and outcome effects refer to the same allele (the exposure effect
   allele). Resolve strand differences by complementing alleles. For palindromic variants (A/T or C/G), infer the strand
   from allele frequency when the minor allele frequency is at most 0.42; otherwise drop the variant. Record the
   harmonisation action for every variant.
3. **Units.** Express exposure effects per kg/m² (1 SD of BMI = 4.8 kg/m²).
4. **Estimate.** Primary: inverse-variance weighted (IVW), multiplicative random effects. Sensitivity: MR-Egger
   (report the intercept) and weighted median. Report Cochran's Q for IVW.
5. **Outputs.**
   - `results/harmonisation_log.csv`: one row per variant, with its harmonisation action and whether it was used
   - `results/estimates.csv`: `method, estimate, se, ci_lower, ci_upper, n_snps`
   - `results/figures/scatter.png`: SNP–outcome against SNP–exposure effects, with the fitted lines
   - `report.md`: at most 200 words for the research group
