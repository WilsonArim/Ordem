#!/usr/bin/env bash
# Fábrica — pre-commit: mantém TOC atualizado e reforça disciplina
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo ".")"
cd "$ROOT"

# Se existir o updater, corre e adiciona TOC
if [ -x "./fabrica/update_pipeline_toc.sh" ]; then
  echo "🧭 Atualizando PIPELINE_TOC.md…"
  ./fabrica/update_pipeline_toc.sh >/dev/null || {
    echo "❌ Falha a atualizar TOC"; exit 1;
  }
  git add pipeline/PIPELINE_TOC.md 2>/dev/null || true
fi

# Corre o validador SOP — bloqueia commit se falhar
if [ -x "./fabrica/validate_sop.sh" ]; then
  echo "🛡️  Validando SOP antes do commit…"
  if ! ./fabrica/validate_sop.sh >/dev/null; then
    echo "❌ Commit bloqueado: SOP inválido. Veja ./fabrica/validate_sop.sh"
    exit 1
  fi
fi

echo "✅ Pre-commit ok."