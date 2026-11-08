#!/usr/bin/env bash
# Empaqueta las líneas de dependencia del commit del vault que fija packaging.json.
#
#   tools/package.sh --vault <clon del vault>           escribe packages/ y el marketplace
#   tools/package.sh --vault <clon del vault> --check   solo compara; sale con 1 si difieren
#
# Lee el vault con git archive en el commit fijado, nunca su copia de trabajo.
# Conserva version:, cada ref: ya escrita y CHANGELOG.md: son de la publicación.
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
vault="" check=0
while [ $# -gt 0 ]; do
  case $1 in
    --vault) vault=${2:?falta la ruta del clon}; shift 2 ;;
    --check) check=1; shift ;;
    -h|--help) sed -n '2,8p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "package.sh: argumento desconocido: $1" >&2; exit 2 ;;
  esac
done
[ -n "$vault" ] || { echo "package.sh: falta --vault <clon del vault>" >&2; exit 2; }
vault=$(cd "$vault" && pwd)

commit=$(python3 -I -c 'import json,sys; print(json.load(open(sys.argv[1]))["vault"]["commit"])' "$root/packaging.json")
[[ $commit =~ ^[0-9a-f]{40}$ ]] || { echo "package.sh: vault.commit debe ser un SHA completo" >&2; exit 3; }
git -C "$vault" cat-file -e "$commit^{commit}" 2>/dev/null \
  || { echo "package.sh: el clon no tiene $commit. Prueba: git -C $vault fetch origin $commit" >&2; exit 3; }

tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
audit=${TMPDIR:-/tmp}/cdn-taller-audit/${commit:0:7}
mkdir -p "$tmp/vault" "$tmp/exports" "$tmp/out/packages" "$audit"
git -C "$vault" archive "$commit" | tar -x -C "$tmp/vault"

# Una exportación completa por fila, con el export.sh del propio commit fijado.
# El destino queda fuera de la carpeta del vault, como pide su export.sh.
lines=$(python3 -I -c 'import json,sys; cfg=json.load(open(sys.argv[1])); print("\n".join(row["line"] for row in cfg["packages"]))' "$root/packaging.json")
for leaf in $lines; do
  if ! (cd "$tmp" && bash "$tmp/vault/tools/export.sh" --root "$tmp/vault" "$leaf" "$tmp/exports/$leaf") > "$audit/$leaf.txt" 2>&1; then
    cat "$audit/$leaf.txt" >&2
    echo "package.sh: el export de $leaf ha fallado" >&2; exit 4
  fi
done

python3 -I - "$root" "$tmp" <<'PY'
import filecmp, json, os, re, shutil, sys
root, tmp = sys.argv[1:3]
cfg = json.load(open(os.path.join(root, "packaging.json")))
rows = {p["name"]: p for p in cfg["packages"]}
repo = cfg["cdn"]["repo"]
TYPES = ("skills", "instructions", "agents", "hooks")

def die(msg, code=4):
    print("package.sh: " + msg, file=sys.stderr); sys.exit(code)

def assets(tree):
    """Cada asset entero: una skill es su carpeta; un hook, los ficheros con su mismo nombre base."""
    found = {}
    for t in TYPES:
        d = os.path.join(tree, t)
        if not os.path.isdir(d):
            continue
        for entry in sorted(os.listdir(d)):
            key = (t, entry if t != "hooks" else entry.split(".")[0])
            found.setdefault(key, []).append(os.path.join(d, entry))
    return found

def same(a, b):
    if os.path.isdir(a) != os.path.isdir(b):
        return False
    if os.path.isfile(a):
        return filecmp.cmp(a, b, shallow=False)
    cmp = filecmp.dircmp(a, b)
    if cmp.left_only or cmp.right_only or cmp.funny_files:
        return False
    if any(not filecmp.cmp(os.path.join(a, f), os.path.join(b, f), shallow=False) for f in cmp.common_files):
        return False
    return all(same(os.path.join(a, s), os.path.join(b, s)) for s in cmp.common_dirs)

def closure(name, seen=None):
    seen = [] if seen is None else seen
    for dep in rows[name].get("dependsOn", []):
        if dep not in rows:
            die(f"{name} depende de {dep}, que no es una fila de packaging.json")
        if dep not in seen:
            closure(dep, seen); seen.append(dep)
    return seen

def kept(path, key):
    m = re.search(rf"^{key}:\s*(\S+)", open(path).read(), re.M) if os.path.exists(path) else None
    return m.group(1).strip('"') if m else None

def kept_ref(path, dep):
    if not os.path.exists(path):
        return None
    m = re.search(rf'path:\s*"packages/{re.escape(dep)}"\s*\n\s*ref:\s*"([^"]+)"', open(path).read())
    return m.group(1) if m else None

listed = []
for name, row in rows.items():
    exp = os.path.join(tmp, "exports", row["line"])
    if os.path.exists(os.path.join(exp, "mcp.json")):
        die(f"{row['line']} declara servidores MCP; este CDN de práctica no los empaqueta")
    own = assets(exp)
    for dep in closure(name):
        for key, paths in assets(os.path.join(tmp, "exports", rows[dep]["line"])).items():
            mine = own.get(key)
            if not mine or len(mine) != len(paths) or not all(
                    same(p, os.path.join(exp, key[0], os.path.basename(p))) for p in paths):
                die(f"{name} no contiene {key[0]}/{key[1]} de {dep} idéntico: quita la dependencia o arregla el vault", 5)
            del own[key]
    out = os.path.join(tmp, "out", "packages", name)
    for (t, _), paths in own.items():
        os.makedirs(os.path.join(out, ".apm", t), exist_ok=True)
        for p in paths:
            dst = os.path.join(out, ".apm", t, os.path.basename(p))
            (shutil.copytree if os.path.isdir(p) else shutil.copy2)(p, dst)
    old = os.path.join(root, "packages", name)
    manifest = json.load(open(os.path.join(tmp, "vault", "asset-sets", row["line"], "manifest.json")))
    version = kept(os.path.join(old, "apm.yml"), "version") or "1.0.0"
    lines = [f"name: {name}", f"version: {version}",
             f"description: {json.dumps(manifest['description'], ensure_ascii=False)}", "includes: auto"]
    deps = row.get("dependsOn", [])
    if deps:
        lines += ["dependencies:", "  apm:"]
        for dep in deps:
            ref = kept_ref(os.path.join(old, "apm.yml"), dep) or "^" + (kept(os.path.join(root, "packages", dep, "apm.yml"), "version") or "1.0.0")
            lines += [f'    - git: "{repo}"', f'      path: "packages/{dep}"', f'      ref: "{ref}"']
    os.makedirs(out, exist_ok=True)
    open(os.path.join(out, "apm.yml"), "w").write("\n".join(lines) + "\n")
    if os.path.exists(os.path.join(old, "CHANGELOG.md")):
        shutil.copy2(os.path.join(old, "CHANGELOG.md"), os.path.join(out, "CHANGELOG.md"))
    if row.get("listed"):
        listed.append({"name": name, "description": manifest["description"],
                       "source": {"source": "git-subdir", "url": repo, "path": f"packages/{name}",
                                  "ref": f"^{version.split('.')[0]}.0.0"}})

mp = {"name": cfg["cdn"]["marketplace"], "owner": {"name": cfg["cdn"]["owner"]}, "plugins": listed}
os.makedirs(os.path.join(tmp, "out", ".claude-plugin"))
open(os.path.join(tmp, "out", ".claude-plugin", "marketplace.json"), "w").write(
    json.dumps(mp, indent=2, ensure_ascii=False) + "\n")
PY

if [ "$check" = 1 ]; then
  # diff -r compara contenidos; el bit de ejecución se compara aparte.
  modes() { (cd "$1" && find . -type f -perm -u+x | LC_ALL=C sort); }
  if diff -r "$tmp/out/packages" "$root/packages" \
     && diff "$tmp/out/.claude-plugin/marketplace.json" "$root/.claude-plugin/marketplace.json" \
     && diff <(modes "$tmp/out/packages") <(modes "$root/packages"); then
    echo "ok: packages/ es lo que sale del vault en ${commit:0:7}"; exit 0
  fi
  echo "package.sh: packages/ no coincide con el vault en ${commit:0:7}. Vuelve a empaquetar." >&2; exit 1
fi
rm -rf "$root/packages" "$root/.claude-plugin"
cp -a "$tmp/out/packages" "$tmp/out/.claude-plugin" "$root/"
echo "ok: empaquetado el vault en ${commit:0:7}. Lee la auditoría de cada línea en $audit/ y el git diff antes del commit."
