#!/usr/bin/env bash
set -euo pipefail

echo "🔍 Auditoria SOP iniciada..."
errors=0

fail() { echo "❌ $1"; errors=$((errors+1)); }

# -------- Helpers --------
has_line() {
  local file="$1"; local pattern="$2"
  grep -qiE "$pattern" "$file"
}

is_template_line() {
  # ignora IDs de exemplo
  [[ "$1" =~ ID:\ \[YYYY-MM-DD-XXX\] ]]
}

# -------- 0) Existência mínima --------
[ -f "fabrica/ORDER_TEMPLATE.md" ] || fail "Falta fabrica/ORDER_TEMPLATE.md"
[ -f "fabrica/CLAUDE_QUEUE.md" ]   || fail "Falta fabrica/CLAUDE_QUEUE.md"
[ -f "fabrica/relatorio.md" ]      || fail "Falta fabrica/relatorio.md"

# -------- 1) ORDER_TEMPLATE deve ter cláusulas obrigatórias --------
if [ -f "fabrica/ORDER_TEMPLATE.md" ]; then
  has_line "fabrica/ORDER_TEMPLATE.md" "RELATORIO\.MD ATUALIZADO" \
    || fail "ORDER_TEMPLATE.md sem cláusula obrigatória: 'RELATORIO.MD ATUALIZADO'."
  has_line "fabrica/ORDER_TEMPLATE.md" "^##\s*CICLO DE RESPONSABILIDADES" \
    || fail "ORDER_TEMPLATE.md sem a secção: 'CICLO DE RESPONSABILIDADES'."
fi

# -------- 2) Ordens ativas (CLAUDE_QUEUE.md) devem respeitar cláusulas --------
if [ -s "fabrica/CLAUDE_QUEUE.md" ]; then
  # Só valida se parece conter uma ordem (tem um ID:)
  if grep -q "^ID:\s" "fabrica/CLAUDE_QUEUE.md"; then
    has_line "fabrica/CLAUDE_QUEUE.md" "RELATORIO\.MD ATUALIZADO" \
      || fail "CLAUDE_QUEUE.md sem cláusula 'RELATORIO.MD ATUALIZADO' (ordem inválida)."
    has_line "fabrica/CLAUDE_QUEUE.md" "^##\s*CICLO DE RESPONSABILIDADES" \
      || fail "CLAUDE_QUEUE.md sem secção 'CICLO DE RESPONSABILIDADES' (ordem inválida)."
  fi
fi

# -------- 3) IDs (YYYY-MM-DD-###) em documentos (ignora templates) --------
while IFS= read -r line; do
  # ignora linhas de template
  is_template_line "$line" && continue
  id=$(echo "$line" | sed -nE 's/^ID:\s*([0-9-]+).*/\1/p')
  if [ -n "${id:-}" ] && [[ ! "$id" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{3}$ ]]; then
    fail "ID inválido encontrado: '$line'"
  fi
done < <(grep -Rhn "^ID:\s" fabrica treino_torre 2>/dev/null || true)

# -------- 4) Checklist format (- [ ] ou - [x]) --------
while IFS= read -r line; do
  [[ "$line" =~ ^-?\ \[[x\ ]\]\  ]] || fail "Checklist mal formatada: '$line'"
done < <(grep -Rh "^\- \[.\]" fabrica treino_torre 2>/dev/null || true)

# -------- 5) Frontmatter das Aulas (treino_torre) --------
if [ -d "treino_torre" ]; then
  for f in treino_torre/*.md; do
    [ -f "$f" ] || continue
    # ignora ficheiros que não são aulas
    case "$(basename "$f")" in
      README.md|TOC.md|AULA_TEMPLATE.md) continue ;;
    esac
    # tem frontmatter?
    if awk 'NR==1{exit !($0=="---")}' "$f"; then
      # extrai chaves
      for key in id capitulo etapa tarefa estado_final; do
        grep -qE "^${key}:\ " "$f" || fail "Aula '$f' sem chave obrigatória no frontmatter: ${key}"
      done
      # valida id
      id=$(grep -E "^id:\ " "$f" | awk '{print $2}')
      [[ "$id" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{3}$ ]] || fail "Aula '$f' com ID inválido: $id"
    else
      fail "Aula '$f' sem frontmatter YAML (---)."
    fi
  done
fi

# -------- 6) Estados permitidos (se aparecerem) --------
if grep -Rqh "^STATUS:\s" fabrica 2>/dev/null; then
  while IFS= read -r line; do
    # ignora templates com [TODO|...]
    [[ "$line" =~ \[.*\|.*\] ]] && continue
    status=$(echo "$line" | sed -nE 's/^STATUS:\s*(.*)$/\1/p' | tr -d '[:space:]')
    [[ "$status" =~ ^(TODO|EM_PROGRESSO|EM_REVISAO|AGUARDA_GATEKEEPER|DONE)$ ]] \
      || fail "STATUS inválido: '$line'"
  done < <(grep -Rhn "^STATUS:\s" fabrica 2>/dev/null || true)
fi

# -------- Resultado --------
if [ $errors -eq 0 ]; then
  echo "✅ SOP válido: todas as verificações passaram."
  exit 0
else
  echo "❌ Auditoria falhou com $errors erro(s)."
  exit 1
fi