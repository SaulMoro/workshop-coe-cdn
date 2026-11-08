#!/usr/bin/env bash
# check-on-stop.sh: hook Stop. Cuando el agente termina en un vault, ejecuta tools/verify.sh.
# Si verify falla, devuelve sus errores al agente (salida 2) para que los corrija.
# Un solo reintento: si vuelve a fallar con los mismos cambios, o si el cliente avisa de que
# el hook ya bloqueó una vez (stop_hook_active), termina sin bloquear.
# Fuera de un vault (sin tools/verify.sh) no hace nada.
set -u

input="$(cat)"
if printf '%s' "$input" | grep -Eq '"stop_hook_active"[[:space:]]*:[[:space:]]*true'; then
  exit 0
fi
[ -f tools/verify.sh ] || exit 0

git_dir="$(git rev-parse --git-dir 2>/dev/null || true)"
last=""
[ -n "$git_dir" ] && last="$git_dir/check-on-stop.last"

if output="$(bash tools/verify.sh 2>&1)"; then
  [ -n "$last" ] && rm -f "$last"
  exit 0
fi

if [ -n "$last" ]; then
  key="$({ git diff HEAD 2>/dev/null; git status --porcelain 2>/dev/null; } | git hash-object --stdin)"
  if [ -f "$last" ] && [ "$(cat "$last")" = "$key" ]; then
    exit 0
  fi
  printf '%s\n' "$key" > "$last"
fi

{
  echo "tools/verify.sh ha encontrado errores en el vault. Corrígelos antes de terminar:"
  printf '%s\n' "$output" | grep -E '^(error|   )' || printf '%s\n' "$output"
} >&2
exit 2
