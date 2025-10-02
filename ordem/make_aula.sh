#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 6 ]; then
  echo "Uso: $0 <ID> <CAPITULO> <ETAPA> <TAREFA> <SLUG> <TAGS>"
  echo "Ex:  ./ordem/make_aula.sh 2025-09-30-001 M01 E01 T001 micro-gama-jwt 'jwt,rbac,fastapi'"
  exit 1
fi

ID="$1"; CAP="$2"; ETA="$3"; TAR="$4"; SLUG="$5"; TAGS="$6"
DEST="treino_torre/${ID}-${SLUG}.md"

[ -d "treino_torre" ] || mkdir -p "treino_torre"

cat > "$DEST" <<EOF
---
id: ${ID}
capitulo: ${CAP}
etapa: ${ETA}
tarefa: ${TAR}
tags: [${TAGS}]
estado_final: DONE
---

# Aula — [${CAP}/${ETA}/${TAR}] ${SLUG//-/ }

## 1) ORDEM (resumo)
- Contexto: TODO
- Ação: TODO
- Critérios: TODO

## 2) PATCH (essência)
- Ficheiros tocados: TODO
- Principais alterações/padrões: TODO

## 3) PROBLEMA ENCONTRADO
- Sintoma: TODO
- Evidência: TODO

## 4) CAUSA RAIZ (RCA)
- TODO

## 5) SOLUÇÃO
- TODO

## 6) TESTES
- Unit: TODO
- E2E: TODO

## 7) GATEKEEPER
- 7/7 PASSOU

## 8) LIÇÕES/PLAYBOOK
- Checklist:
  - TODO
- Snippets:
\`\`\`txt
TODO
\`\`\`

## 9) LINKS
- Ordem: ordem/codex_claude/CLAUDE_QUEUE.md (ID ${ID})
- Relatório: ordem/codex_claude/relatorio.md
- Commit: TODO
EOF

echo "✅ Aula criada: $DEST"
