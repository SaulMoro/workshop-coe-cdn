#!/usr/bin/env bash
# scan-dated.sh: marca dated patterns en el texto de los assets (ficheros *.md).
# Se salta el frontmatter, los bloques de código y el texto entre comillas invertidas.
# Un aviso no es un veredicto: cada uno se clasifica con references/dated-catalog.md.
#
# Uso: scan-dated.sh <fichero|carpeta>...
#      scan-dated.sh --list
#      scan-dated.sh --help
# Salida: 0 (haya o no avisos) · 2 uso incorrecto
set -u

usage() {
  cat <<'EOF'
Uso: scan-dated.sh <fichero|carpeta>...
     scan-dated.sh --list
     scan-dated.sh --help

Marca dated patterns en los *.md: texto pensado para modelos anteriores.
Imprime «fichero:línea  id  texto» por aviso y el total al final.
Se salta el frontmatter, los bloques de código y el texto `entre comillas invertidas`.

Salida: 0 (haya o no avisos) · 2 uso incorrecto
EOF
}

list() {
  cat <<'EOF'
ID              QUÉ MARCA
pressure-caps   palabras de presión en mayúsculas: ALWAYS, NEVER, MUST, IMPORTANT, CRITICAL
step-by-step    muletillas de razonamiento: think step by step, think carefully, take a deep breath
identity-stub   identidad de relleno al empezar una frase: You are an expert…, You are a senior…
EOF
}

if [ $# -eq 0 ]; then
  usage >&2
  exit 2
fi
case "$1" in
  -h | --help) usage; exit 0 ;;
  --list) list; exit 0 ;;
  -*) echo "scan-dated.sh: opción desconocida: $1" >&2; exit 2 ;;
esac

files=""
for target in "$@"; do
  target="${target%/}"
  if [ -d "$target" ]; then
    files="$files$(find "$target" -type f -name '*.md' -print | LC_ALL=C sort)
"
  elif [ -f "$target" ]; then
    files="$files$target
"
  else
    echo "scan-dated.sh: no existe $target" >&2
    exit 2
  fi
done

hits="$(printf '%s' "$files" | sed '/^$/d' | while IFS= read -r file; do
  awk -v file="$file" '
    function hit(id) { printf "%s:%d  %-13s  %s\n", file, FNR, id, shown }
    { sub(/\r$/, "") }
    FNR == 1 && $0 == "---" { front = 1; next }
    front { if ($0 == "---") front = 0; next }
    /^[ \t]*(```|~~~)/ { fence = !fence; next }
    fence { next }
    {
      text = $0
      gsub(/`[^`]*`/, "", text)
      lower = tolower(text)
      shown = $0
      sub(/^[ \t]+/, "", shown)
      if (text ~ /(^|[^A-Za-z])(ALWAYS|NEVER|MUST|IMPORTANT|CRITICAL)([^A-Za-z]|$)/) hit("pressure-caps")
      if (lower ~ /think (step[- ]by[- ]step|carefully)|take a deep breath|let.?s think/) hit("step-by-step")
      if (lower ~ /(^|[.!?] )[ \t]*([-*+] |[0-9]+\. )?you are (an?|the) [a-z -]*(expert|senior|specialist|engineer|developer|assistant)/) hit("identity-stub")
    }' "$file"
done)"

if [ -n "$hits" ]; then
  printf '%s\n' "$hits"
  count="$(printf '%s\n' "$hits" | wc -l | tr -d ' ')"
else
  count=0
fi

case "$count" in
  0) echo "0 avisos." ;;
  1) echo "1 aviso. Un aviso no es un veredicto: clasifícalo con references/dated-catalog.md." ;;
  *) echo "$count avisos. Un aviso no es un veredicto: clasifica cada uno con references/dated-catalog.md." ;;
esac
exit 0
