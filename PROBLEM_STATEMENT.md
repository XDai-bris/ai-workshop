# Problem statement

**Does higher body mass index (BMI) causally raise systolic blood pressure (SBP)?**

You have **simulated** GWAS summary statistics in `data/` for a two-sample Mendelian randomization (MR)
analysis. Your goal is to estimate the causal effect of BMI on SBP, in **mmHg per 1 kg/m² higher BMI**, for the
dataset in `data/main/`. Start with `data/DATA_DICTIONARY.md`.

Work with your AI to write a specification in `spec/spec.md`, using `spec/spec_template.md`, **before any analysis
code is written**.

> **MR in one paragraph.** Genetic variants that affect BMI are inherited at random at conception, so they act
> like a natural randomised trial. If BMI raises SBP, variants that raise BMI should also raise SBP, in proportion.
> MR estimates the causal effect from that proportion across many variants. It relies on assumptions; the key
> one is that the variants affect SBP *only through* BMI. Variants that violate it ("pleiotropy") can bias the answer.

Two **control datasets with known answers** are provided (`data/control_positive/`, `data/control_negative/`).
The true answer for `data/main/` is hidden and will be revealed at the end of the session.
