# Data dictionary

> **All data in this folder are SIMULATED** for the IEU AI-for-coding workshop. They describe no real
> people, variants or GWAS. Variant identifiers are synthetic.

## Folders

Each folder holds one exposure GWAS file and one outcome GWAS file in the same formats.

| Folder | Purpose | True causal effect of BMI on SBP |
|---|---|---|
| `control_positive/` | Control dataset with a known answer | **+0.30 mmHg per 1 kg/m²** |
| `control_negative/` | Control dataset with a known answer | **0.00 mmHg per 1 kg/m²** (no causal effect) |
| `main/` | The dataset for the research question | Unknown |

## `exposure_bmi_gwas.tsv` (exposure: body mass index)

Genetic instruments for BMI from a GWAS of 300,000 people: independent variants (r² < 0.001)
associated with BMI at P < 5×10⁻⁸, pre-selected by the exposure consortium.
The exposure consortium does not guarantee which DNA strand alleles are reported on.

| Column | Meaning |
|---|---|
| `SNP` | Variant identifier |
| `CHR`, `POS` | Chromosome and position (GRCh38) |
| `EFFECT_ALLELE` | Allele whose effect is reported |
| `OTHER_ALLELE` | Other allele |
| `EAF` | Frequency of `EFFECT_ALLELE` |
| `BETA` | Per-copy effect of `EFFECT_ALLELE` on BMI, in **standard-deviation units** (1 SD of BMI = 4.8 kg/m²) |
| `SE` | Standard error of `BETA` (same units) |
| `P` | P-value |
| `N` | Sample size |

## `outcome_sbp_gwas.tsv` (outcome: systolic blood pressure)

Look-up of the BMI instruments in a separate GWAS of SBP (750,000 people, no sample overlap with the
exposure GWAS). Alleles are reported on the forward strand of GRCh38. Some instruments were not
available in the outcome GWAS.
**Missing values are coded as `-9`.**

| Column | Meaning |
|---|---|
| `rsid` | Variant identifier |
| `chr`, `pos` | Chromosome and position (GRCh38) |
| `A1` | Reference allele |
| `A2` | Alternative allele. **`beta` and `freq` refer to `A2`** |
| `freq` | Frequency of `A2` |
| `beta` | Per-copy effect of `A2` on SBP, in mmHg |
| `se` | Standard error of `beta` |
| `pval` | P-value |
| `n` | Sample size |
