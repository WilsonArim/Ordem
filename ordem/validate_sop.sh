#!/usr/bin/env bash
set -euo pipefail

SELF_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SELF_DIR/.." && pwd)"
cd "$REPO_ROOT"

echo "🔍 Auditoria SOP iniciada…"
errors=0
fail(){ echo "❌ $1"; errors=$((errors+1)); }
ok(){   echo "✅ $1"; }

# -------- Helpers --------
has_line_ci(){ grep -qiE "$2" "$1"; }

# Lê valor "ID: ..." (aceita **ID**:) de uma linha
line_has_date_id(){
  echo "$1" | grep -qiE '(^|\*\*)ID(\*\*)?:[[:space:]]*[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{3}[[:space:]]*$'
}
line_has_code_id(){
  # aceita ID: M01 | E01 | T001
  echo "$1" | grep -qiE '(^|\*\*)ID(\*\*)?:[[:space:]]*(M[0-9]{2}|E[0-9]{2}|T[0-9]{3})[[:space:]]*$'
}

# -------- 0) Existência mínima --------
[ -f "ordem/Manuais/ORDER_TEMPLATE.md" ] || fail "Falta ordem/Manuais/ORDER_TEMPLATE.md"
[ -f "ordem/codex_claude/CLAUDE_QUEUE.md" ]   || fail "Falta ordem/codex_claude/CLAUDE_QUEUE.md"
[ -f "ordem/codex_claude/relatorio.md" ]      || fail "Falta ordem/codex_claude/relatorio.md"

# -------- 1) ORDER_TEMPLATE: cláusulas de ferro --------
if [ -f "ordem/Manuais/ORDER_TEMPLATE.md" ]; then
  has_line_ci "ordem/Manuais/ORDER_TEMPLATE.md" "RELATORIO\.MD ATUALIZADO" \
    || fail "ORDER_TEMPLATE.md sem cláusula 'RELATORIO.MD ATUALIZADO'."
  has_line_ci "ordem/Manuais/ORDER_TEMPLATE.md" "^##[[:space:]]*CICLO DE RESPONSABILIDADES" \
    || fail "ORDER_TEMPLATE.md sem secção 'CICLO DE RESPONSABILIDADES'."

  # Secção Git / Controlo de Versão (se existir)
  if has_line_ci "ordem/Manuais/ORDER_TEMPLATE.md" "GIT[[:space:]]*/[[:space:]]*CONTROLO DE VERS(Ã|A)O"; then
    has_line_ci "ordem/Manuais/ORDER_TEMPLATE.md" "Só executar Git após 7/7 PASSOU" \
      || fail "ORDER_TEMPLATE.md: bloco Git sem a regra 'Só executar Git após 7/7 PASSOU'."
    # Aceitar placeholder, real ou genérico
    has_line_ci "ordem/Manuais/ORDER_TEMPLATE.md" "\\[ORD-(YYYY-MM-DD-XXX|[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{3}|ID)\\]" \
      || fail "ORDER_TEMPLATE.md: bloco Git sem padrão de commit '[ORD-YYYY-MM-DD-XXX]' (ou equivalente)."
  fi
  ok "ORDER_TEMPLATE.md — cláusulas de ferro presentes"
fi

# -------- 2) CLAUDE_QUEUE.md (se tiver ordem) --------
if [ -s "ordem/codex_claude/CLAUDE_QUEUE.md" ] && grep -q "^ID:\s" "ordem/codex_claude/CLAUDE_QUEUE.md"; then
  has_line_ci "ordem/codex_claude/CLAUDE_QUEUE.md" "RELATORIO\.MD ATUALIZADO" \
    || fail "CLAUDE_QUEUE.md sem 'RELATORIO.MD ATUALIZADO'."
  has_line_ci "ordem/codex_claude/CLAUDE_QUEUE.md" "^##[[:space:]]*CICLO DE RESPONSABILIDADES" \
    || fail "CLAUDE_QUEUE.md sem 'CICLO DE RESPONSABILIDADES'."
  ok "CLAUDE_QUEUE.md — formato de ordem válido"
fi

# -------- 3) IDs válidos --------
# Regras:
# - Em ordem/ e treino_torre/: ID deve ser data (ORD-id ou aulas).
# - Em pipeline/: ID deve bater com o código do ficheiro (Mxx/Eyy/Tzzz).
while IFS= read -r -d '' f; do
  case "$f" in
    ./pipeline/_templates/*|./pipeline/PIPELINE_TOC.md|./treino_torre/AULA_TEMPLATE.md) continue;;
  esac
  while IFS= read -r line; do
    # Ignorar placeholders de template
    echo "$line" | grep -qiE 'YYYY-MM-DD-XXX' && continue
    case "$f" in
      ./pipeline/*)
        # Determinar o tipo pelo nome do ficheiro
        base="$(basename "$f" .md)"
        if [[ "$base" =~ ^M[0-9]{2}$ ]]; then
          line_has_code_id "$line" || fail "ID inválido em '$f': $line"
        elif [[ "$base" =~ ^E[0-9]{2}$ ]]; then
          line_has_code_id "$line" || fail "ID inválido em '$f': $line"
        elif [[ "$base" =~ ^T[0-9]{3}$ ]]; then
          line_has_code_id "$line" || fail "ID inválido em '$f': $line"
        else
          # Se for outro markdown na pipeline, não forçar ID
          :
        fi
        ;;
      *)
        # ordem/ e treino_torre/
        line_has_date_id "$line" || fail "ID inválido em '$f': $line"
        ;;
    esac
  done < <(grep -iE '(^|\*\*)ID(\*\*)?:[[:space:]]' "$f" || true)
done < <(find ./fabrica ./pipeline ./treino_torre -type f -name "*.md" -print0 2>/dev/null)

# -------- 4) Checklists Markdown (sem confundir TOC) --------
# Apenas linhas do tipo '- [ ] ' ou '- [x] ' são checklists; o resto ignora-se.
while IFS= read -r -d '' f; do
  # ignorar TOC e templates
  case "$f" in ./pipeline/PIPELINE_TOC.md|./pipeline/_templates/*) continue;; esac
  # detetar linhas que começam por "- [" mas NÃO são "- [ ]" nem "- [x]"
  awk '
    $0 ~ /^- \[/ && $0 !~ /^- \[ \]/ && $0 !~ /^- \[x\]/ { print FILENAME ":" FNR ": " $0 }
  ' "$f" | while read -r bad; do
    fail "Checklist mal formatada em '$f': ${bad#*: }"
  done
done < <(find ./fabrica ./pipeline ./treino_torre -type f -name "*.md" -print0 2>/dev/null)

# -------- 5) Aulas (treino_torre) — frontmatter --------
if [ -d "treino_torre" ]; then
  shopt -s nullglob
  for f in treino_torre/*.md; do
    case "$f" in *AULA_TEMPLATE.md|*TOC.md|*README.md) continue;; esac
    [ -f "$f" ] || continue
    if ! awk 'NR==1{exit !($0=="---")}' "$f"; then
      fail "Aula '$f' sem frontmatter YAML (---)"; continue
    fi
    for key in id capitulo etapa tarefa estado_final; do
      grep -qE "^${key}:\ " "$f" || fail "Aula '$f' sem chave obrigatória: ${key}"
    done
    id=$(grep -E "^id:\ " "$f" | awk '{print $2}')
    [[ "$id" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{3}$ ]] || fail "Aula '$f' com ID inválido: $id"
  done
  ok "Aulas — frontmatter validado"
fi

# -------- 6) Pipeline — STATUS (ignora _templates/TOC) --------
if [ -d "pipeline" ]; then
  allowed="(TODO|EM_PROGRESSO|EM_REVISAO|AGUARDA_GATEKEEPER|DONE)"
  while IFS= read -r -d '' f; do
    # extrair STATUS com awk
    st="$(awk -F': ' 'tolower($1)=="status"{print $2; exit}' "$f" || echo "")"
    if [ -n "$st" ]; then
      st_clean="$(echo "$st" | tr -d '[:space:]')"
      [[ "$st_clean" =~ ^$allowed$ ]] || fail "STATUS inválido em '$f': $st"
    fi
  done < <(find ./pipeline -type f -name "*.md" ! -path "./pipeline/_templates/*" ! -name "PIPELINE_TOC.md" -print0 2>/dev/null)
  ok "Pipeline — STATUS válidos (templates/TOC ignorados)"
fi

# ---------- 6b) Pipeline — TASKS precisam de >= 2 critérios ----------
# Procura a secção "## CRITÉRIOS" (com ou sem acento) e conta checklists "- [ ]" ou "- [x]" até ao próximo "## "
if [ -d "pipeline" ]; then
  while IFS= read -r -d '' tfile; do
    # Usamos padrões que aceitam É ou E: CRIT(E|É)RIOS (aceita texto adicional no título)
    cnt="$(
      awk '
        BEGIN{ in_section=0; c=0; }
        /^[[:space:]]*##[[:space:]]*CRIT(E|É)RIOS/ { in_section=1; next }
        /^[[:space:]]*##[[:space:]]+/ && in_section==1 { in_section=0 }
        in_section==1 && $0 ~ /^- \[[ x]\]/ { c++ }
        END{ print c }
      ' "$tfile"
    )"
    if [ "${cnt:-0}" -lt 2 ]; then
      fail "TASK com critérios insuficientes (mín. 2): $tfile (encontrados: ${cnt:-0})"
    fi
  done < <(find ./pipeline -type f -name "T[0-9][0-9][0-9].md" ! -path "./pipeline/_templates/*" -print0 2>/dev/null)
  ok "Pipeline — todas as TASKs com >= 2 critérios"
fi
# -------- 7) SOP.md (validar só se existir) --------
if [ -f "ordem/Manuais/SOP.md" ]; then
  has_line_ci "ordem/Manuais/SOP.md" "^#\s*SOP\b" || fail "SOP.md sem título 'SOP'."
  has_line_ci "ordem/Manuais/SOP.md" "Fluxo de Linha de Montagem.*Inviol(á|a)vel" \
    || fail "SOP.md sem secção 'Fluxo de Linha de Montagem (Inviolável)'."
  has_line_ci "ordem/Manuais/SOP.md" "Comandante|Estado-Maior|Codex|Engenheiro|Operador" \
    || fail "SOP.md sem definição de papéis."
  ok "SOP.md — seções essenciais presentes"
fi

# -------- 8) Kit Codex (opcional) --------
[ -f "ordem/verifica_luz_verde.sh" ] && [ -x "ordem/verifica_luz_verde.sh" ] && ok "Inspetor presente (executável)" || true
[ -f "ordem/Manuais/CODEX_ONBOARDING.md" ] && ok "CODEX_ONBOARDING.md presente" || true
[ -f ".vscode/tasks.json" ] && ok "VSCode tasks presentes" || true

# -------- Resultado --------
if [ $errors -eq 0 ]; then
  echo "✅ SOP válido: todas as verificações passaram."
  exit 0
else
  echo "❌ Auditoria falhou com $errors erro(s)."
  exit 1
fi