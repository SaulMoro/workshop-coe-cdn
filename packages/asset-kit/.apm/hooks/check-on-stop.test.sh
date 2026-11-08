#!/usr/bin/env bash
# Tests de check-on-stop.sh. Autónomo: no depende de las herramientas del vault.
set -u

HOOK="$(cd "$(dirname "$0")" && pwd -P)/check-on-stop.sh"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/check-on-stop.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT
failures=0

check() { # descripción, esperado, obtenido
  if [ "$2" = "$3" ]; then echo "ok - $1"; else echo "FALLO - $1 (esperado: $2, obtenido: $3)"; failures=$((failures + 1)); fi
}

repo="$WORK/repo"
mkdir -p "$repo/tools"
cd "$repo" || exit 1
git init -q .
git config user.name test
git config user.email test@example.com
cat > tools/verify.sh <<'SH'
#!/usr/bin/env bash
echo "error  manifests   algo falla"
exit 1
SH
echo uno > notes.txt
git add -A && git -c commit.gpgsign=false commit -qm base

echo '{"stop_hook_active": false}' | bash "$HOOK" 2> "$WORK/err" > /dev/null
check "si verify falla, sale con 2" 2 "$?"
grep -q 'algo falla' "$WORK/err"
check "y escribe los errores en stderr" 0 "$?"

echo '{}' | bash "$HOOK" 2> /dev/null > /dev/null
check "con los mismos cambios, la segunda vez sale con 0" 0 "$?"

echo dos > notes.txt
echo '{}' | bash "$HOOK" 2> /dev/null > /dev/null
check "con cambios nuevos, vuelve a bloquear" 2 "$?"

echo '{"stop_hook_active": true}' | bash "$HOOK" 2> /dev/null > /dev/null
check "con stop_hook_active, sale con 0" 0 "$?"

cat > tools/verify.sh <<'SH'
#!/usr/bin/env bash
echo "resultado: 0 errores, 0 avisos"
SH
echo '{}' | bash "$HOOK" 2> /dev/null > /dev/null
check "si verify pasa, sale con 0" 0 "$?"
[ -f "$(git rev-parse --git-dir)/check-on-stop.last" ]
check "y borra la huella del último fallo" 1 "$?"

rm -rf tools
echo '{}' | bash "$HOOK" 2> /dev/null > /dev/null
check "sin tools/verify.sh (un repositorio consumidor), sale con 0" 0 "$?"

[ "$failures" -eq 0 ]
