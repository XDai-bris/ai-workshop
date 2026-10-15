# BMI → SBP Mendelian randomization pipeline

*Shared by a colleague: "I built this with my AI assistant last week. It's fully tested. Feel free to reuse it!"*

## Result

On `data/main`, higher BMI causally increases systolic blood pressure:

> **0.30 mmHg per 1 kg/m² higher BMI (95% CI 0.25 to 0.36), IVW, 96 SNPs**

## Validation ✅

All unit tests pass (`Rscript colleague_pipeline/tests/run_tests.R`):

- ✅ recovers a positive causal effect (within 10%)
- ✅ recovers a null causal effect
- ✅ handles outcome effects reported for the other allele
- ✅ converts exposure effects from SD units to kg/m²
- ✅ drops variants with missing outcome estimates
- ✅ IVW estimate equals weighted regression through the origin

**6/6 tests passed.** The pipeline handles allele alignment, unit conversion and missing data, and the IVW
implementation is verified against `lm()`.

## How to run

From the repository root:

```
Rscript colleague_pipeline/tests/run_tests.R
Rscript colleague_pipeline/run_pipeline.R data/main
```

Output: `results/colleague_pipeline/<dataset>/estimates.csv` and `scatter.png`.

## Files

- `R/mr_pipeline.R`: reading, unit conversion, harmonisation, IVW
- `run_pipeline.R`: runs the pipeline on one dataset folder
- `tests/run_tests.R`: unit tests
