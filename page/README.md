# Page sources

`validation_walkthrough.html` at the repository root is built from these files. Do not edit it by hand.

| File | What it is |
|---|---|
| `template.html` | The page shell: header, stage map, take-home messages |
| `stage1.html` … `stage6.html`, `reading.html`, `provenance.html` | One fragment per section |
| `style.css`, `script.js` | Inlined into the page |
| `sources.json` | Maps each placeholder to a file under `runs/` |
| `zip_readme.txt` | The README inside the downloadable case files |
| `build_page.py` | Fills the placeholders and writes the page |

Placeholders in the fragments:

- `{{PROMPT:key}}`: a prompt, verbatim.
- `{{REPLY:key}}`: the final reply from a transcript, verbatim.
- `{{FILE:key}}`: a file, verbatim.
- `{{INC:name}}`: another fragment.
- `{{ZIP}}`: the case-file download, built from the `ZIP` section of `sources.json`.

Build from the repository root:

    python3 page/build_page.py validation_walkthrough.html

The build stops if any placeholder is left unfilled. It is deterministic, so a rebuild with no source changes gives an
identical file; CI checks this on every push.
