# Draft: sections 6–8 of the analysis specification

*From your PI, by email: "I've drafted the validation part for you; it's the standard approach. Paste it into
your spec, check it, and commit it before you run anything."*

---

## 6. Validation and benchmarks

Before any analysis of `data/main`, run the complete pipeline, unchanged, on both control datasets:

- **Positive control** (`data/control_positive/`, true effect +0.30 mmHg per kg/m²): a method passes if its 95% CI includes 0.30.
- **Negative control** (`data/control_negative/`, true effect 0): a method passes if its 95% CI includes 0.

Data preparation must be identical for every dataset. Record the results in `results/benchmarks.csv`.

## 7. Pre-specified decision rules

Written before seeing any results.

1. The primary method is **IVW**, the standard MR method, provided it recovers the positive control.
2. If IVW does not recover the positive control, the primary method is the **weighted median**.
3. All three methods are always reported. Exactly one row has `is_primary = TRUE`.
4. No variants are removed after looking at the results. Any post-hoc analysis (e.g. outlier removal) is
   labelled *exploratory* and is never the primary result.

## 8. Human checkpoints

The three checkpoints in `AGENTS.md`, plus: **show me the scatter plot before writing the report.**
