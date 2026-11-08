#!/usr/bin/env bash
# Comprueba el CDN antes de cada commit y de cada push.
#
#   tools/check.sh                      estructura, etiquetas, nombres y texto oculto
#   tools/check.sh --denylist <fichero> además, ninguna línea del fichero aparece en el repositorio
#
# El fichero de --denylist vive fuera del repositorio: lo que lista no se publica.
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
deny=""
case ${1:-} in
  "") ;;
  --denylist) deny=${2:?falta el fichero}; deny=$(cd "$(dirname "$deny")" && pwd)/$(basename "$deny") ;;
  -h|--help) sed -n '2,7p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
  *) echo "check.sh: argumento desconocido: $1" >&2; exit 2 ;;
esac
cd "$root"
fail=0
err() { echo "check.sh: $*" >&2; fail=1; }

# 1. Etiquetas: solo <paquete>--v<x.y.z>, anotadas. Una v1.0.0 o una 1.0.0 entrarían en el rango de todos los paquetes.
#    Cada una apunta a un commit donde el apm.yml del paquete dice esa versión y su CHANGELOG.md la explica.
xyz='[0-9]+\.[0-9]+\.[0-9]+'
while read -r tag; do
  [ -z "$tag" ] && continue
  if [[ ! $tag =~ ^([a-z0-9-]+)--v($xyz)$ ]]; then err "etiqueta no permitida: $tag"; continue; fi
  name=${BASH_REMATCH[1]} ver=${BASH_REMATCH[2]}
  [ "$(git cat-file -t "$tag")" = tag ] || err "$tag no es una etiqueta anotada"
  got=$(git show "$tag:packages/$name/apm.yml" 2>/dev/null | sed -n 's/^version: *//p')
  [ "$got" = "$ver" ] || err "$tag apunta a un commit donde packages/$name/apm.yml dice version: ${got:-(nada)}"
  log=$(git show "$tag:packages/$name/CHANGELOG.md" 2>/dev/null || true)
  grep -qx "## $ver" <<<"$log" \
    || err "$tag apunta a un commit donde packages/$name/CHANGELOG.md no tiene la sección ## $ver"
done < <(git tag --list)

# 2. Nombres y rangos: carpeta = name de apm.yml = entrada del marketplace, con ^<major>.0.0.
python3 -I - <<'PY' || fail=1
import json, os, re, sys
bad = []
try:
    cfg = json.load(open("packaging.json"))
    mp = json.load(open(".claude-plugin/marketplace.json"))
    os.listdir("packages")
except (OSError, ValueError) as e:
    print(f"check.sh: falta o no se lee packaging.json, .claude-plugin/marketplace.json o packages/"
          f" (¿has ejecutado tools/package.sh?): {e}", file=sys.stderr)
    sys.exit(1)
if not re.fullmatch(r"[0-9a-f]{40}", cfg["vault"]["commit"]):
    bad.append("packaging.json: vault.commit no es un SHA completo")
if mp.get("name") != cfg["cdn"]["marketplace"]:
    bad.append(f"el marketplace se llama {mp.get('name')} y packaging.json dice {cfg['cdn']['marketplace']}")
rows = [p["name"] for p in cfg["packages"]]
if sorted(rows) != sorted(os.listdir("packages")):
    bad.append(f"packages/ tiene {sorted(os.listdir('packages'))} y packaging.json {sorted(rows)}")
entries = {e["name"]: e for e in mp["plugins"]}
if [e["name"] for e in mp["plugins"]] != [p["name"] for p in cfg["packages"] if p["listed"]]:
    bad.append("el orden o la lista de entradas del marketplace no es la de packaging.json")
for p in cfg["packages"]:
    d = f"packages/{p['name']}"
    extra = set(os.listdir(d)) - {"apm.yml", "CHANGELOG.md", ".apm"}
    if extra:
        bad.append(f"{d} solo admite apm.yml, CHANGELOG.md y .apm/: sobra {sorted(extra)}")
    y = open(f"{d}/apm.yml").read()
    name = re.search(r"^name: (\S+)", y, re.M).group(1)
    ver = re.search(r"^version: (\S+)", y, re.M).group(1)
    if name != p["name"]:
        bad.append(f"{d}/apm.yml se llama {name}")
    if not re.fullmatch(r"[0-9]+\.[0-9]+\.[0-9]+", ver):
        bad.append(f"{d}/apm.yml: version {ver} no es x.y.z")
    if p["listed"] != (p["name"] in entries):
        bad.append(f"{p['name']}: listed={p['listed']} y el marketplace no coincide")
    e = entries.get(p["name"])
    if e and (e["source"]["source"] != "git-subdir" or e["source"]["path"] != d
              or e["source"]["ref"] != f"^{ver.split('.')[0]}.0.0" or e["source"]["url"] != cfg["cdn"]["repo"]):
        bad.append(f"la entrada {p['name']} del marketplace no apunta a {d} en ^{ver.split('.')[0]}.0.0")
for b in bad:
    print("check.sh: " + b, file=sys.stderr)
sys.exit(1 if bad else 0)
PY

# 3. Ningún paquete usa un nombre que ya tiene workshop-coe: chocarían en el repositorio del taller.
for n in loading-states api-errors list-a11y ui-reviewer ui proyecto check-loading; do
  hit=$(find packages -path '*/.apm/*' \( -name "$n" -o -name "$n.*" \) -print -quit)
  [ -z "$hit" ] || err "$hit usa el nombre $n, que ya existe en workshop-coe"
done

# 4. Texto oculto: espacios de ancho cero, controles bidi y caracteres de etiqueta. apm audit los bloquea.
if git ls-files -z | LC_ALL=C.UTF-8 xargs -0 grep -lP '[\x{200B}-\x{200F}\x{202A}-\x{202E}\x{2066}-\x{2069}\x{FEFF}\x{E0000}-\x{E007F}]' 2>/dev/null; then
  err "hay caracteres ocultos en los ficheros de arriba"
fi

# 5. Lista de bloqueo privada.
if [ -n "$deny" ]; then
  if git ls-files -z | xargs -0 grep -n -i -F -f "$deny" 2>/dev/null; then err "aparece texto de la lista de bloqueo"; fi
  if git log --all --format='%an %ae %cn %ce %B' | grep -i -F -f "$deny"; then err "la lista de bloqueo aparece en el historial"; fi
fi

[ "$fail" = 0 ] && echo "ok: CDN listo"
exit "$fail"
