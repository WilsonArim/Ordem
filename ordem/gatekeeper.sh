#!/usr/bin/env bash
set -euo pipefail

echo "🚦 Início do Gatekeeper"

tests=(
  "ESLint::npx eslint ."
  "Prettier::npx prettier -c ."
  "Semgrep::semgrep --config auto"
  "Gitleaks::gitleaks detect --no-git -c ordem/.gitleaks.toml"
  "npm audit::npm audit --audit-level=high"
  "pip-audit::pip-audit -r requirements.txt"
  "Sentry::grep -Riq 'sentry' . && grep -q 'SENTRY_DSN' .env.example"
)

i=1
for test in "${tests[@]}"; do
  name="${test%%::*}"
  cmd="${test##*::}"

  echo "[${i}/7] $name → RUNNING..."
  if eval $cmd; then
    echo "[${i}/7] $name → ✅ PASSOU"
  else
    echo "[${i}/7] $name → ❌ FALHOU"
    echo "   Motivo: comando '$cmd' devolveu erro."
    exit 1
  fi
  i=$((i+1))
done

echo "✅ GATEKEEPER: TODOS OS TESTES PASSARAM"
