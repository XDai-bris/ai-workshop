# The simulated case

Two-sample MR of BMI on systolic blood pressure, on simulated GWAS summary statistics. Base R only.

## Files

| Path | What it is |
|---|---|
| `project_template/` | What the agent starts from: `analysis_plan.md`, `data/DATA_DICTIONARY.md`, `data/main/` and the agent notes (`AGENTS.md`, `CLAUDE.md`) |
| `extra_data/control_positive/` | A second dataset with a known answer (true effect 0.30). It is not given to the agent |
| `truth/` | Per-SNP simulation truth and the configuration used. Never copy it into an agent's project |
| `R/sim_functions.R` | The simulator |
| `R/mr_functions.R` | A reference MR pipeline (harmonisation, IVW, MR-Egger, weighted median) |
| `generate_case.R` | Writes the data and the truth from a fixed seed |
| `check_case.R` | Fits the correct pipeline and the planted bug (E2) to both datasets |
| `select_case_seed.R` | The seed search |

## The model

100 independent BMI instruments. For SNP *j*, defined on its BMI-raising allele:

- true SNP–BMI effect γ_j = 0.01 + Exp(mean 0.012) SD per allele, and at least 7 × SE;
- true SNP–SBP effect Γ_j = θ × 4.8 × γ_j + α_j, with α_j ~ N(0, 0.005²) mmHg (balanced pleiotropy);
- θ = 0.25 mmHg per kg/m² (1 SD of BMI = 4.8 kg/m²).

Allele frequencies are uniform on 0.05–0.95. Standard errors are 1/√(2f(1−f)N) with N = 300,000 for BMI, and
19 mmHg/√(2f(1−f)N) with N = 750,000 for SBP. BMI estimates are redrawn until P < 5×10⁻⁸. The files then carry the
hazards real summary statistics have: BMI effects in SD units, effect alleles chosen at random in each file (the
outcome beta refers to A2), 48 variants on the opposite strand in the outcome, 8 palindromic variants (4 with MAF
0.43–0.49), 3 rows with the missing-value code `-9`, and 4 instruments absent from the outcome file.

A correct analysis keeps 89 instruments and gives IVW 0.207 (95% CI 0.150 to 0.264).

## Seed

The seed (20261125) is the first from 20261124 that met criteria fixed before the search: the correct pipeline's
intervals contain the truth in both datasets, and the planted bug fails the known-answer check clearly
(see `select_case_seed.R`).

## Commands

From the repository root:

    conda run -n ieu-ai-workshop Rscript case/generate_case.R

From this folder:

    conda run -n ieu-ai-workshop Rscript check_case.R
    conda run -n ieu-ai-workshop Rscript select_case_seed.R
