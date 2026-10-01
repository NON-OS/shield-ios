#!/usr/bin/env python3
"""What the app links and what each part is licensed under.

Walks the core's resolved dependency graph for each device target, normal
dependencies only, since build tools and tests do not ship. Writes one line per
crate, and every licence and notice file those crates carry, deduplicated by
content: MIT, BSD and Apache all ask for their notice to travel with the
binary, and a name in a list does not do that.

A crate with no declared licence stops the build, because shipping it would be
shipping something nobody gave permission for.
"""

import hashlib
import json
import pathlib
import subprocess
import sys

NOTICE_PREFIXES = ("license", "licence", "copying", "notice", "copyright")
# The standard texts, for a crate that declares a licence and ships no file for
# it. The app's own licence covers the AGPL entries.
STANDARD = {"MIT": "MIT.txt", "Apache-2.0": "Apache-2.0.txt", "MPL-2.0": "MPL-2.0.txt"}


def graph(core, targets):
    """The union over every target the app ships a library for."""
    found = {}
    for target in targets.split(","):
        found.update({p["id"]: p for p in graph_for(core, target)})
    return list(found.values())


def graph_for(core, target):
    out = subprocess.run(
        ["cargo", "metadata", "--format-version", "1", "--locked",
         "--filter-platform", target, "--manifest-path", str(core / "Cargo.toml")],
        check=True, capture_output=True, text=True).stdout
    meta = json.loads(out)
    pkgs = {p["id"]: p for p in meta["packages"]}
    nodes = {n["id"]: n for n in meta["resolve"]["nodes"]}
    root = next(i for i, p in pkgs.items() if p["name"] == "nox_shield_core")
    seen, todo = set(), [root]
    while todo:
        cur = todo.pop()
        if cur in seen:
            continue
        seen.add(cur)
        for dep in nodes[cur]["deps"]:
            if any(k["kind"] is None for k in dep["dep_kinds"]):
                todo.append(dep["pkg"])
    return [pkgs[i] for i in seen if i != root]


def notices(pkg):
    here = pathlib.Path(pkg["manifest_path"]).parent
    found = [f for f in sorted(here.iterdir())
             if f.is_file() and f.name.lower().startswith(NOTICE_PREFIXES)]
    if pkg.get("license_file"):
        extra = here / pkg["license_file"]
        if extra.is_file() and extra not in found:
            found.append(extra)
    return found


def spdx_ids(expr):
    return {t for t in expr.replace("(", " ").replace(")", " ").replace("/", " OR ").split()
            if t not in ("OR", "AND", "WITH")}


def main(core, root, fonts, standard, target):
    lines = ["nox_shield_core (this project) : GNU AGPL v3.0 or later"]
    texts, owners, missing, bare = {}, {}, [], {}
    for pkg in sorted(graph(core, target), key=lambda p: (p["name"], p["version"])):
        name = f'{pkg["name"]} {pkg["version"]}'
        files = notices(pkg)
        licence = pkg.get("license") or ("see its licence file" if files else None)
        if licence is None:
            missing.append(name)
            continue
        lines.append(f"{name} : {licence}")
        if not files:
            authors = ", ".join(pkg.get("authors") or []) or "its authors"
            for spdx in spdx_ids(licence) & STANDARD.keys():
                bare.setdefault(spdx, []).append(f"{name} ({authors})")
        for f in files:
            body = f.read_text(encoding="utf-8", errors="replace").strip()
            key = hashlib.sha256(body.encode()).hexdigest()
            texts.setdefault(key, body)
            owners.setdefault(key, []).append(name)
    for face in sorted(fonts):
        lines.append(f"{face} : SIL Open Font License 1.1")
    if missing:
        sys.exit("no licence declared by: " + ", ".join(missing))
    root.mkdir(parents=True, exist_ok=True)
    (root / "licences.txt").write_text("\n".join(lines) + "\n")
    blocks = [f'{", ".join(owners[k])}\n\n{texts[k]}' for k in sorted(texts, key=lambda k: owners[k][0])]
    for spdx in sorted(bare):
        body = (standard / STANDARD[spdx]).read_text().strip()
        blocks.append(f'{spdx}, for:\n' + "\n".join(bare[spdx]) + f"\n\n{body}")
    (root / "licence-texts.txt").write_text("\n\n\f\n\n".join(blocks) + "\n")
    print(f"licences: {len(lines)} entries, {len(texts)} distinct texts")


if __name__ == "__main__":
    # core checkout, output directory, standard texts, targets (comma separated), faces...
    core, out, standard = (pathlib.Path(a) for a in sys.argv[1:4])
    main(core, out, sys.argv[5:], standard, sys.argv[4])
