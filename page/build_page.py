"""Assemble validation_walkthrough.html from the template, recorded transcripts and case files.

Placeholders in template.html:
  {{CSS}} {{SCRIPT}}                 inline style / script
  {{INC:name}}                       HTML fragment page/<name>.html (may contain placeholders)
  {{PROMPT:key}} {{REPLY:key}}       verbatim prompt text / final agent reply (HTML-escaped)
  {{FILE:key}}                       verbatim file content (HTML-escaped)
  {{ZIP}}                            base64 data URI of the case workspace zip
"""
import base64, html, io, json, os, re, sys, zipfile

PAGE = os.path.dirname(os.path.abspath(__file__))
BASE = os.path.dirname(PAGE)
# recorded runs live in ../runs (working copy) or ../raw (facilitator archive)
RUNS = os.path.join(BASE, "runs") if os.path.isdir(os.path.join(BASE, "runs")) else os.path.join(BASE, "raw")
CONF = json.load(open(os.path.join(PAGE, "sources.json")))


def reply(path):
    res = None
    for line in open(path):
        try:
            m = json.loads(line)
        except ValueError:
            continue
        if m.get("type") == "result":
            res = m.get("result")
    if res is None:
        sys.exit(f"no result in {path}")
    return res


def esc(t):
    return html.escape(t.rstrip("\n"), quote=False)


def get(kind, key):
    src = CONF[kind][key]
    p = src if os.path.isabs(src) else os.path.join(RUNS, src)
    if kind == "REPLY":
        return esc(reply(p))
    return esc(open(p, encoding="utf-8").read())


def add(z, arc, data):
    """Add a member with a fixed time and mode, so the page rebuilds byte-identically from any checkout."""
    info = zipfile.ZipInfo(arc, date_time=(2026, 11, 24, 0, 0, 0))
    info.compress_type = zipfile.ZIP_DEFLATED
    info.external_attr = 0o644 << 16
    z.writestr(info, data)


def build_zip():
    buf = io.BytesIO()
    with zipfile.ZipFile(buf, "w", zipfile.ZIP_DEFLATED) as z:
        for arc, src in CONF["ZIP"].items():
            p = src if os.path.isabs(src) else os.path.join(RUNS, src)
            if os.path.isdir(p):
                for root, dirs, files in os.walk(p):
                    dirs[:] = sorted(d for d in dirs if d not in (".git", "scratch", "review"))
                    for f in sorted(files):
                        if f in (".DS_Store",):
                            continue
                        full = os.path.join(root, f)
                        add(z, os.path.join(arc, os.path.relpath(full, p)), open(full, "rb").read())
            elif src.endswith(".jsonl"):
                add(z, arc, (reply(p) + "\n").encode("utf-8"))
            else:
                add(z, arc, open(p, "rb").read())
    return "data:application/zip;base64," + base64.b64encode(buf.getvalue()).decode()


def fill(text, depth=0):
    def sub(m):
        kind, key = m.group(1), m.group(2)
        if kind == "INC":
            return fill(open(os.path.join(PAGE, key + ".html"), encoding="utf-8").read(), depth + 1)
        if kind in ("PROMPT", "REPLY", "FILE"):
            return get(kind, key)
        sys.exit(f"unknown placeholder {kind}:{key}")
    return re.sub(r"\{\{(INC|PROMPT|REPLY|FILE):([\w.-]+)\}\}", sub, text)


tpl = open(os.path.join(PAGE, "template.html"), encoding="utf-8").read()
out = fill(tpl)
out = out.replace("{{CSS}}", open(os.path.join(PAGE, "style.css")).read())
out = out.replace("{{SCRIPT}}", open(os.path.join(PAGE, "script.js")).read())
if "{{ZIP}}" in out:
    out = out.replace("{{ZIP}}", build_zip())
left = re.findall(r"\{\{[^}]+\}\}", out)
if left:
    sys.exit(f"unfilled placeholders: {sorted(set(left))}")
dest = sys.argv[1] if len(sys.argv) > 1 else os.path.join(PAGE, "validation_walkthrough.html")
open(dest, "w", encoding="utf-8").write(out)
print(f"wrote {dest} ({len(out)/1024:.0f} KB)")
