#!/usr/bin/env bash
set -euo pipefail

# ---------------- Setup / Paths ----------------
SELF_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SELF_DIR/.." && pwd)"   # assume ordem/ está na raiz
cd "$REPO_ROOT"

# ---------------- Options ----------------
VERBOSE=0
USE_COLOR=1
REQUIRE_GK=0
RUN_GK_WHEN_READY=0

for arg in "${@:-}"; do
  case "$arg" in
    --verbose) VERBOSE=1 ;;
    --no-color) USE_COLOR=0 ;;
    --require-gatekeeper) REQUIRE_GK=1 ;;
    --run-gatekeeper-when-ready) RUN_GK_WHEN_READY=1; REQUIRE_GK=1 ;;
    *) ;;
  esac
done

# ---------------- Colors ----------------
if [ $USE_COLOR -eq 1 ] && [ -t 1 ]; then
  RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
else
  RED=''; GREEN=''; YELLOW=''; BLUE=''; NC=''
fi

say() { echo -e "$1"; }
info() { [ $VERBOSE -eq 1 ] && say "${BLUE}ℹ️  $*${NC}"; }
ok()   { say "${GREEN}✅ $*${NC}"; }
warn() { say "${YELLOW}⚠️  $*${NC}"; }
fail() { say "${RED}❌ BLOQUEADO: $*${NC}"; }

echo "🔍 Inspetor Codex — verificação de luz verde…"

# Exit code map:
# 0 = VERDE | 10 = PRONTO PARA GATEKEEPER
# 1 = BLOQUEADO genérico | 2 = SOP inválido | 3 = relatório ausente
# 4 = relatório incompleto | 5 = checklist incompleta
# 6 = GK não executado | 7 = GK falhou

# ---------------- 1) SOP ----------------
say "1/4 Validando SOP…"
if ! ./ordem/validate_sop.sh >/dev/null 2>&1; then
  fail "SOP inválido — execute './ordem/validate_sop.sh' para detalhes."
  exit 2
fi
ok "SOP válido"

# ---------------- 2) Relatório ----------------
say "2/4 Verificando relatorio.md…"
REL="ordem/codex_claude/relatorio.md"
[ -f "$REL" ] || { fail "Falta $REL"; exit 3; }

need_blocks=("PLAN" "PATCH" "TESTS" "SELF-CHECK")
missing=()
for b in "${need_blocks[@]}"; do
  if ! grep -qiE "^#{2,}\s*${b}\b" "$REL"; then
    missing+=("$b")
  fi
done
if [ "${#missing[@]}" -gt 0 ]; then
  fail "Relatório incompleto — faltam blocos: ${missing[*]}"
  exit 4
fi

# Checklist marcada dentro de SELF-CHECK
if ! awk '
  BEGIN{IGNORECASE=1; in_section=0; ok=0}
  /^##+ *SELF-CHECK/{in_section=1; next}
  /^##+ /{in_section=0}
  in_section && $0 ~ /^- *\[x\]/ { ok=1 }
  END{exit ok?0:1}
' "$REL"; then
  fail "SELF-CHECK sem itens marcados (ex.: '- [x] …')."
  exit 5
fi
ok "Relatório completo (PLAN/PATCH/TESTS/SELF-CHECK) e checklist OK"

# ---------------- 3) Gatekeeper ----------------
say "3/4 Verificando estado do Gatekeeper…"
gk_ran=0
gk_pass=0

if grep -qiE "7/7 +PASSOU|Gatekeeper.*7/7.*PASSOU|✅.*7/7" "$REL"; then
  gk_ran=1; gk_pass=1
elif grep -qiE "❌.*Gatekeeper|FALHOU.*Gatekeeper|Gatekeeper.*falhou" "$REL"; then
  gk_ran=1; gk_pass=0
fi

if [ $gk_ran -eq 0 ]; then
  if [ $REQUIRE_GK -eq 1 ]; then
    if [ $RUN_GK_WHEN_READY -eq 1 ]; then
      warn "Gatekeeper ainda não correu — a executar './ordem/gatekeeper.sh'…"
      if ./ordem/gatekeeper.sh; then
        gk_ran=1; gk_pass=1
      else
        gk_ran=1; gk_pass=0
      fi
    fi
  fi
fi

if [ $gk_ran -eq 0 ]; then
  warn "🟡 PRONTO PARA GATEKEEPER — execute './ordem/gatekeeper.sh'."
  exit 10
fi

if [ $gk_pass -eq 0 ]; then
  fail "Gatekeeper executado mas com falhas — corrija e reexecute."
  exit 7
fi
ok "Gatekeeper executado e 7/7 PASSOU"

# ---------------- 4) Veredicto ----------------
say "4/4 Verificação final…"
say "${GREEN}🟢 VERDE${NC} — Tudo validado: SOP ✓, Relatório ✓, Gatekeeper 7/7 ✓. Pronto para Git."
exit 0