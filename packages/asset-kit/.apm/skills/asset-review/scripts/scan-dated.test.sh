#!/usr/bin/env bash
# Tests de scan-dated.sh. Autónomo: no depende de las herramientas del vault.
set -u

HERE="$(cd "$(dirname "$0")" && pwd -P)"
SCAN="$HERE/scan-dated.sh"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/scan-dated.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT
failures=0

check() { # descripción, esperado, obtenido
  if [ "$2" = "$3" ]; then echo "ok - $1"; else echo "FALLO - $1"; printf '  esperado: %s\n  obtenido: %s\n' "$2" "$3"; failures=$((failures + 1)); fi
}

# El api-errors de front-ui-states, con sus tres dated patterns en las líneas 12, 18 y 24.
mkdir -p "$WORK/set/skills/api-errors"
cat > "$WORK/set/skills/api-errors/SKILL.md" <<'EOF'
---
name: api-errors
description: Show API errors the way this team does, with ErrorBanner and a retry. Use when a request handles a failed API call in a page or form.
---

# API errors

1. Wrap the part of the page that reads server data in `ApiErrorBoundary` from `src/shared/ui/ApiErrorBoundary.tsx`. Create it if it is missing, as a class error boundary.
2. Its fallback is always `ErrorBanner` from `src/shared/ui/ErrorBanner.tsx`, with the error message and `onRetry`.
3. Retrying clears the cached query of that feature (`reset…Query()`) and renders again.

ALWAYS use <ErrorBanner> for API errors. NEVER show a raw error, an alert or an empty list instead.

## Retry

1. The page keeps an `attempt` counter and passes `key={attempt}` to `ApiErrorBoundary`.
2. `onRetry` calls `reset…Query()` and increments `attempt`.
Think step by step before you write the retry.

## Check

- Open the page with `?fail=1`: the banner shows instead of a blank page.

You are an expert React developer who never lets an API error reach the user unhandled.
EOF

out="$(bash "$SCAN" "$WORK/set")"
check "api-errors: tres avisos, en las líneas 12, 18 y 24, con sus ids" \
  "SKILL.md:12 pressure-caps|SKILL.md:18 step-by-step|SKILL.md:24 identity-stub|" \
  "$(printf '%s\n' "$out" | grep ':[0-9]' | sed -E 's#^.*/##; s/  +/ /g' | cut -d' ' -f1,2 | tr '\n' '|')"
check "api-errors: el total dice 3 avisos" "3" "$(printf '%s\n' "$out" | tail -n 1 | cut -d' ' -f1)"

cat > "$WORK/quiet.md" <<'EOF'
---
description: ALWAYS in the frontmatter does not count
---

Inline code such as `NEVER do this` is skipped.

```text
ALWAYS inside a code block is skipped.
You are an expert inside a code block too.
```

Mixed case words like Never or Important are fine, and so is IMPORTANTE.
EOF
check "frontmatter, bloques de código y spans no se marcan" "0 avisos." "$(bash "$SCAN" "$WORK/quiet.md")"

printf -- '- You are a senior engineer who reviews code.\r\n' > "$WORK/crlf.md"
check "una identidad en un elemento de lista, con CRLF, se marca" "1" "$(bash "$SCAN" "$WORK/crlf.md" | grep -c 'identity-stub')"

bash "$SCAN" > /dev/null 2>&1
check "sin argumentos sale con 2" 2 "$?"
bash "$SCAN" "$WORK/no-existe" > /dev/null 2>&1
check "con una ruta que no existe sale con 2" 2 "$?"

# Dentro del vault, sus propios sets no enseñan lo que critican.
vault_sets="$HERE/../../../.."
if [ -d "$vault_sets/asset-kit" ] && [ -d "$vault_sets/../tools" ]; then
  check "los asset-sets del vault dan 0 avisos" "0 avisos." "$(bash "$SCAN" "$vault_sets" | tail -n 1)"
fi

[ "$failures" -eq 0 ]
