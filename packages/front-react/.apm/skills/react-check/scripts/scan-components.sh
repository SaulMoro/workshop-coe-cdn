#!/usr/bin/env bash
# scan-components.sh: busca en componentes React tres señales de problemas de render.
# Solo lee ficheros. Imprime «fichero:línea · problema» y el total.
#
# Uso: scan-components.sh <carpeta|fichero>...
# Salida: 0 (haya o no hallazgos) · 2 uso incorrecto
set -u

if [ $# -eq 0 ]; then
  echo "Uso: scan-components.sh <carpeta|fichero>..." >&2
  exit 2
fi
case "$1" in
  -h | --help)
    echo "Uso: scan-components.sh <carpeta|fichero>..."
    echo "Busca keys por índice, fetch dentro de useEffect y componentes declarados dentro de otro."
    exit 0 ;;
esac

files=""
for target in "$@"; do
  if [ -d "$target" ]; then
    files="$files$(find "$target" \( -name '*.tsx' -o -name '*.jsx' \) -type f ! -path '*/node_modules/*' | LC_ALL=C sort)
"
  elif [ -f "$target" ]; then
    files="$files$target
"
  else
    echo "No existe $target" >&2
    exit 2
  fi
done

findings="$(printf '%s' "$files" | sed '/^$/d' | while IFS= read -r file; do
  awk -v file="$file" '
    { sub(/\r$/, "") }
    /key=\{(i|idx|index)\}/ { print file ":" NR " · key por índice: usa un id estable del elemento" }
    /useEffect\(/ { effect = 8 }
    effect > 0 && /fetch\(/ { print file ":" NR " · fetch dentro de useEffect: lee los datos con una fuente compatible con Suspense"; effect = 0 }
    effect > 0 { effect-- }
    /^(export )?(default )?function [A-Z]/ { component = 1; next }
    component && /^[ \t]+(function [A-Z][A-Za-z0-9]*\(|const [A-Z][A-Za-z0-9]* = \()/ { print file ":" NR " · componente declarado dentro de otro: muévelo al nivel del módulo" }
  ' "$file"
done)"

if [ -n "$findings" ]; then
  printf '%s\n' "$findings"
  count="$(printf '%s\n' "$findings" | wc -l | tr -d ' ')"
else
  count=0
fi
if [ "$count" -eq 1 ]; then echo "1 hallazgo."; else echo "$count hallazgos."; fi
exit 0
