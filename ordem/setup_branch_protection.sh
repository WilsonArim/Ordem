#!/usr/bin/env bash
set -euo pipefail

echo "🔒 Ordem — Ativar Branch Protection (CI obrigatória)"

# 0) Pré-requisitos
command -v gh >/dev/null 2>&1 || { echo "❌ Necessário GitHub CLI (gh) autenticado: gh auth login"; exit 1; }
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "❌ Não é um repo git."; exit 1; }

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

# 1) Owner/Repo e branch principal
REMOTE="$(git remote get-url origin 2>/dev/null || true)"
if [[ -z "${REMOTE}" ]]; then
  echo "❌ Não encontrei 'origin'. Faz: git remote add origin git@github.com:<owner>/<repo>.git"
  exit 1
fi

if [[ "$REMOTE" =~ github\.com[:/](.+)/(.+)(\.git)?$ ]]; then
  OWNER="${BASH_REMATCH[1]}"
  REPO="${BASH_REMATCH[2]}"
  # Remove .git suffix if present
  REPO="${REPO%.git}"
else
  echo "❌ Remote não parece GitHub: $REMOTE"; exit 1
fi

BRANCH="$(git symbolic-ref --short HEAD 2>/dev/null || echo "main")"
# tenta descobrir defaultBranch no GitHub
DEFAULT_BRANCH="$(gh repo view "${OWNER}/${REPO}" --json defaultBranchRef -q .defaultBranchRef.name 2>/dev/null || echo "${BRANCH}")"
BRANCH="${DEFAULT_BRANCH}"

echo "📦 Repo: ${OWNER}/${REPO}"
echo "🌿 Branch protegida: ${BRANCH}"

# 2) Determinar nome do check da CI
# Tentamos obter o nome exato do job a partir do último run; fallback para "Ordem CI / ordem-checks"
CHECK_NAME="$(gh run list --repo "${OWNER}/${REPO}" --json name,headBranch -q '.[0].name' 2>/dev/null || true)"
if [[ -z "${CHECK_NAME}" ]]; then
  CHECK_NAME="Ordem CI / ordem-checks"
fi
# Normalizar caso o name seja só "Ordem CI"
if [[ "${CHECK_NAME}" == "Ordem CI" ]]; then
  CHECK_NAME="Ordem CI / ordem-checks"
fi
echo "✅ Status check requerido: ${CHECK_NAME}"

# 3) Construir JSON e aplicar proteção
TMP="$(mktemp)"
cat > "${TMP}" <<JSON
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["${CHECK_NAME}"]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1
  },
  "restrictions": null
}
JSON

echo "🚀 Aplicando proteção…"
gh api -X PUT \
  -H "Accept: application/vnd.github+json" \
  "/repos/${OWNER}/${REPO}/branches/${BRANCH}/protection" \
  --input "${TMP}"

echo "🔎 Validação:"
gh api -H "Accept: application/vnd.github+json" "/repos/${OWNER}/${REPO}/branches/${BRANCH}/protection" | jq '{branch:"'${BRANCH}'", required_status_checks, enforce_admins, required_pull_request_reviews}'

echo "🎉 Branch Protection ativo. Merges só com CI verde (+ review)."
