ID: 2025-09-30-013
PRIORIDADE: Alta
STATUS: DONE

CONTEXTO:
A Fábrica está funcional (pipeline, geradores, TOC, validador, inspetor). Falta “trancar a porta”:

1. TOC atualizar automaticamente no Git,
2. Validador reforçado: cada TASK precisa de ≥2 critérios,
3. Manual final do fluxo e papéis.

AÇÃO:
Blindar a Fábrica (hook + validação adicional) e criar MANUAL.md.

DETALHES (PASSOS CONCRETOS):

1. Criar `ordem/hooks/pre-commit.sh` com o BLOCO A, dar `chmod +x`, e instruir cópia para `.git/hooks/pre-commit`.
2. Atualizar `ordem/validate_sop.sh` adicionando a verificação “CRITÉRIOS ≥ 2” para **todas as TASK.md** (BLOCO B).
3. Criar `ordem/MANUAL.md` com o BLOCO C.
4. Executar:
   - `./ordem/update_pipeline_toc.sh` (uma vez)
   - `./ordem/validate_sop.sh` (deve sair 0)
5. Atualizar `ordem/codex_claude/relatorio.md` (PLAN, PATCH, TESTS, SELF-CHECK).

CRITÉRIOS (mensuráveis):

- [ ] Hook criado, executável e instalado em `.git/hooks/pre-commit`
- [ ] `pre-commit` atualiza TOC e bloqueia commit se o validador falhar
- [ ] `validate_sop.sh` reprova qualquer TASK com `< 2` critérios
- [ ] `ordem/MANUAL.md` criado e completo
- [ ] `./ordem/validate_sop.sh` a verde
- [ ] **RELATORIO.MD ATUALIZADO**

HANDOFF:

- Depois do relatório OK, o Codex corre `./ordem/verifica_luz_verde.sh`:
  - 10 → Operador corre Gatekeeper
  - 0 → Operador faz Git (commit `[ORD-YYYY-MM-DD-XXX] …`)

## CICLO DE RESPONSABILIDADES

- Engenheiro (Claude): aplica BLOCO A+B+C, testa, documenta.
- Codex: decide luz verde via inspetor.
- Estado-Maior (GPT-5): supervisiona doutrina.
- Operador: Gatekeeper/Git apenas após luz verde.

# BLOCO A — ordem/hooks/pre-commit.sh

````bash
#!/usr/bin/env bash
# Fábrica — pre-commit: mantém TOC atualizado e reforça disciplina
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo ".")"
cd "$ROOT"

# Se existir o updater, corre e adiciona TOC
if [ -x "./ordem/update_pipeline_toc.sh" ]; then
  echo "🧭 Atualizando PIPELINE_TOC.md…"
  ./ordem/update_pipeline_toc.sh >/dev/null || {
    echo "❌ Falha a atualizar TOC"; exit 1;
  }
  git add pipeline/PIPELINE_TOC.md 2>/dev/null || true
fi

# Corre o validador SOP — bloqueia commit se falhar
if [ -x "./ordem/validate_sop.sh" ]; then
  echo "🛡️  Validando SOP antes do commit…"
  if ! ./ordem/validate_sop.sh >/dev/null; then
    echo "❌ Commit bloqueado: SOP inválido. Veja ./ordem/validate_sop.sh"
    exit 1
  fi
fi

echo "✅ Pre-commit ok."

Instalação local do hook (Operador):

chmod +x ordem/hooks/pre-commit.sh
cp ordem/hooks/pre-commit.sh .git/hooks/pre-commit



BLOCO B — adição ao ordem/validate_sop.sh (CRITÉRIOS ≥ 2 nas TASKS)

Instruções: inserir este bloco depois da secção “Pipeline — STATUS válidos (…)” e antes da secção “SOP.md (se existir)”.

# ---------- 6b) Pipeline — TASKS precisam de >= 2 critérios ----------
# Em cada arquivo Txxx.md, dentro da secção "## CRITÉRIOS", contar pelo menos 2 checklists (- [ ] ou - [x])
if [ -d "pipeline" ]; then
  while IFS= read -r -d '' tfile; do
    # extrair bloco CRITÉRIOS até ao próximo heading "## "
    cnt="$(awk '
      BEGIN{in=0; c=0}
      tolower($0) ~ /^##[[:space:]]*critérios/ { in=1; next }
      /^##[[:space:]]/ && in==1 { in=0 }
      in==1 && $0 ~ /^- $begin:math:display$[ x]$end:math:display$/ { c++ }
      END{ print c }
    ' "$tfile")"
    if [ "${cnt:-0}" -lt 2 ]; then
      fail "TASK com critérios insuficientes (mín. 2): $tfile"
    fi
  done < <(find ./pipeline -type f -name "T[0-9][0-9][0-9].md" ! -path "./pipeline/_templates/*" -print0 2>/dev/null)
  ok "Pipeline — todas as TASKs com >= 2 critérios"
fi

BLOCO C — ordem/MANUAL.md

# MANUAL da Fábrica

## Papéis
- **Estado-Maior (GPT-5)**: escreve/ajusta SOPs, templates e pipeline.
- **Codex (VSCode/IDE)**: gere o dia-a-dia; decide luz verde via `verifica_luz_verde.sh`.
- **Engenheiro (Claude)**: executa ordens, aplica patches, escreve `relatorio.md`.
- **Operador (Tu)**: corre Gatekeeper e Git, quando autorizado.

## Linha de Montagem (Inviolável)
1. **Ordem** (ORDER_TEMPLATE) → entra em `ordem/codex_claude/CLAUDE_QUEUE.md`.
2. **Execução** (Claude) → aplica PATCH e **atualiza `ordem/codex_claude/relatorio.md`** (PLAN, PATCH, TESTS, SELF-CHECK).
3. **Inspeção** (Codex) → `./ordem/verifica_luz_verde.sh`
   - `🟡 PRONTO PARA GATEKEEPER` (exit 10) → Operador: `./ordem/gatekeeper.sh`
   - `🟢 VERDE` (exit 0) → Git permitido
4. **Gatekeeper** (Operador) → 7/7 PASSOU documentado no relatório.
5. **Git** (Operador) → commit com `[ORD-YYYY-MM-DD-XXX] …` e push.

---

ID: 2025-10-02-023
PRIORIDADE: Alta
STATUS: TODO

CONTEXTO:
Queremos automatizar a disciplina da Ordem no GitHub (CI em cada push/PR e auditoria diária) e tornar explícito que o IDE (Codex) é quem dispara o gatekeeper local e faz commits/PRs. Claude continua como Engenheiro: aplica patch e preenche ordem/relatorio.md.

AÇÃO (o que fazer):
	1.	Criar dois workflows em .github/workflows/:
	•	ordem-ci.yml → corre validate_sop, inspetor, gatekeeper em push/PR.
	•	ordem-advanced.yml → corre Gatekeeper Avançado diariamente (03:00 UTC) e on demand.
	2.	Atualizar documentação de fluxo para "IDE decide Gatekeeping/Commit".
	3.	Validar que tudo corre localmente e no GitHub.
	4.	Deixar relatório feito.

DETALHES (passos concretos):

1) Criar .github/workflows/ordem-ci.yml

Conteúdo:

name: Ordem CI
on:
  push:
    branches: [ main, "**/*" ]
  pull_request:
    branches: [ main ]

jobs:
  ordem-checks:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Preparar permissões
        run: chmod +x ordem/*.sh || true

      - name: Validar SOP
        run: ./ordem/validate_sop.sh

      - name: Inspetor (Luz Verde)
        run: ./ordem/verifica_luz_verde.sh

      - name: Gatekeeper (7/7)
        run: ./ordem/gatekeeper.sh

      - name: Guardar relatórios (artefactos)
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: ordem-relatorios
          path: |
            ordem/relatorio.md
            ordem/*.log
            pipeline/PIPELINE_TOC.md

2) Criar .github/workflows/ordem-advanced.yml

Conteúdo:

name: Ordem Advanced Audit
on:
  schedule:
    - cron: "0 3 * * *"   # todos os dias às 03:00 UTC
  workflow_dispatch: {}    # permite correr manualmente via botão

jobs:
  deep-audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Preparar permissões
        run: chmod +x ordem/*.sh || true

      - name: Gatekeeper Avançado (scan profundo)
        run: ./ordem/gatekeeper_avancado.sh || echo "⚠️ avançado terminou com código != 0"

      - name: Guardar relatórios (artefactos)
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: ordem-advanced-reports
          path: |
            ordem/relatorio.md
            ordem/*.log

3) Atualizar a documentação (fluxo IDE→Gatekeeping/Commit; Claude→Patch/Relatório)
	•	Editar ordem/MANUAL.md e ordem/MANUAL_USO.md:
	•	Secção "Papéis e responsabilidades":
	•	IDE (Codex): lê pipeline, cria CLAUDE_QUEUE.md, dispara gatekeeper local, faz commit/push/PR (Draft), decide avanço.
	•	Engenheiro (Claude): aplica patch, preenche ordem/relatorio.md (PLAN, PATCH, TESTS, SELF-CHECK). Não faz commit.
	•	Secção "Fluxo local" (resumo):
	1.	IDE cria ordine no CLAUDE_QUEUE.md.
	2.	Claude implementa e preenche ordem/relatorio.md.
	3.	IDE corre ./ordem/gatekeeper.sh.
	•	Se falhar: IDE usa wrappers (npm run gatekeeper:*), cria nova ordem para corrigir.
	•	Se 7/7: IDE faz commit/push e abre PR Draft.
	•	Secção "Fluxo GitHub":
	•	Em push/PR, o CI corre automático (ordem-ci.yml).
	•	Quando CI a verde + relatório OK → IDE/Codex muda PR de Draft→Ready e faz merge.

4) Opcional (se existir ordem/bootstrap.sh):
	•	Adicionar nota: "Se o repo tiver remote GitHub, o bootstrap garante a criação/commit dos .github/workflows/*.yml no primeiro push."

5) Executar verificação local:

./ordem/validate_sop.sh
./ordem/verifica_luz_verde.sh || true   # pode devolver "Pronto para Gatekeeper" (exit 10)
./ordem/gatekeeper.sh

6) Git (feito pelo IDE/Codex — não pelo Engenheiro):

git add .github/workflows ordem/MANUAL*.md
git commit -m "[ORD-2025-10-02-023] CI (push/PR) + Auditoria diária + Fluxo: IDE decide Gatekeeping/Commit"
git push -u origin <tua-branch>
# abrir PR como Draft; CI deve correr sozinho

CRITÉRIOS (mensuráveis):
	•	.github/workflows/ordem-ci.yml criado (CI corre em push/PR)
	•	.github/workflows/ordem-advanced.yml criado (cron 03:00 + botão manual)
	•	ordem/MANUAL.md e ordem/MANUAL_USO.md atualizados (IDE decide gatekeeping/commit; Claude só patch+relatório)
	•	CI no PR a verde (ordem-ci.job = sucesso)
	•	RELATORIO.MD ATUALIZADO (PLAN, PATCH, TESTS, SELF-CHECK)

CICLO DE RESPONSABILIDADES:
	•	Engenheiro (Claude): cria/edita os ficheiros YAML, atualiza manuais, corre validações locais, atualiza ordem/relatorio.md.
	•	IDE (Codex): executa gatekeeper.sh local quando necessário, faz commit/push/PR e verifica CI.
	•	Estado-Maior (GPT-5): supervisiona e ajusta a doutrina/SOP.

PRAZO: Hoje.

RELATORIO.MD ATUALIZADO (OBRIGATÓRIO).

---

ID: 2025-10-02-024
PRIORIDADE: Alta
STATUS: TODO

CONTEXTO:
A Ordem já corre CI (GitHub Actions) em push/PR e define o fluxo em que o IDE (Codex) decide Gatekeeping/Commit. Falta trancar a branch principal para que não haja merge sem a CI a verde e, opcionalmente, sem review.

AÇÃO (o que fazer):
Ativar branch protection na branch principal com:
	•	Required status checks: CI "Ordem CI / ordem-checks" obrigatória (strict=true).
	•	Require pull request before merging (1 review, opcional).
	•	Enforce for admins (opcional).
Implementar via script ordem/setup_branch_protection.sh (gh CLI) + documentar fallback via UI.

DETALHES (PASSOS CONCRETOS):
	1.	Criar ordem/setup_branch_protection.sh (executável) com:
	•	Descobrir OWNER/REPO a partir do git remote (SSH ou HTTPS).
	•	Descobrir branch principal (default: main).
	•	Descobrir o nome exato do check da CI a partir do último PR ou último commit (ex.: "Ordem CI / ordem-checks").
	•	Se não conseguir detectar, usar por omissão "Ordem CI / ordem-checks".
	•	Aplicar proteção via gh api:
	•	required_pull_request_reviews.required_approving_review_count = 1 (podes deixar 0 se o review for dispensável).
	•	required_status_checks.strict = true
	•	required_status_checks.contexts = ["Ordem CI / ordem-checks"]
	•	enforce_admins = true
	•	restrictions = null (sem limites de quem pode push).
	•	No final, validar com gh api repos/:owner/:repo/branches/:branch/protection e imprimir o resumo.
	2.	Atualizar ordem/MANUAL_USO.md (secção CI/CD) com:
	•	"Branch Protection ativo: merges só com CI verde (e review se configurado)."
	•	Como verificar no GitHub: Settings → Branches → Rules → main.
	•	Como editar contagens de review, admins, etc.
	3.	Executar local (IDE):

chmod +x ordem/setup_branch_protection.sh
./ordem/setup_branch_protection.sh

	4.	Atualizar ordem/relatorio.md (PLAN, PATCH, TESTS, SELF-CHECK).

BLOCO — ordem/setup_branch_protection.sh

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

TESTS (o que validar):
	•	./ordem/setup_branch_protection.sh termina com sucesso.
	•	gh api repos/<owner>/<repo>/branches/<branch>/protection devolve:
	•	required_status_checks.strict = true
	•	required_status_checks.contexts contém "Ordem CI / ordem-checks"
	•	required_pull_request_reviews.required_approving_review_count = 1 (ou o número definido)
	•	enforce_admins = true (se mantido)

SELF-CHECK:
	•	Script criado e executável
	•	Proteção aplicada na branch principal
	•	CI marcada como status check obrigatório
	•	MANUAL_USO.md atualizado (secção CI/CD → Branch Protection)
	•	RELATORIO.MD ATUALIZADO

CICLO DE RESPONSABILIDADES
	•	Engenheiro (Claude): criar script, testar, atualizar manuais e ordem/relatorio.md.
	•	IDE (Codex): executar o script, confirmar no GitHub (Settings → Branches), abrir PR Drafts, gerir merges.
	•	Estado-Maior (GPT-5): supervisiona e ajusta SOP.

PRAZO: Hoje.
RELATORIO.MD ATUALIZADO (OBRIGATÓRIO).

## Pipeline (Capítulo → Etapa → Tarefa)
- Criar:
  - `./ordem/make_chapter.sh M01 autenticacao`
  - `./ordem/make_stage.sh   M01 E01 base-tokens`
  - `./ordem/make_task.sh    M01 E01 T001 endpoint-login`
- Atualizar TOC: `./ordem/update_pipeline_toc.sh` (também automático no pre-commit).
- **Regras**:
  - Em `pipeline/…/Mxx|Eyy|Tzzz.md`: `ID` é **código** (M/E/T), `STATUS` em {TODO, EM_PROGRESSO, EM_REVISAO, AGUARDA_GATEKEEPER, DONE}.
  - Em `ordem/` e `treino_torre/`: `ID` é **data** `YYYY-MM-DD-XXX`.
  - Em `TASK.md`: secção **CRITÉRIOS** com **≥ 2** itens `- [ ]` / `- [x]` (obrigatório).

## Hooks (Disciplina Automática)
- `ordem/hooks/pre-commit.sh` → atualiza TOC, valida SOP e **bloqueia commit** se falhar.
- Instalação:
  ```bash
  chmod +x ordem/hooks/pre-commit.sh
  cp ordem/hooks/pre-commit.sh .git/hooks/pre-commit

Comandos Essenciais
	•	Validar SOP: ./ordem/validate_sop.sh
	•	Ver luz verde: ./ordem/verifica_luz_verde.sh
	•	Gatekeeper: ./ordem/gatekeeper.sh

Commits (Convenção)
	•	Mensagem deve conter: [ORD-YYYY-MM-DD-XXX] Descrição curta do patch

GIT / CONTROLO DE VERSÃO (após VERDE/Gatekeeper):

git add .
git commit -m “[ORD-2025-09-30-013] Hook pre-commit + validação critérios + MANUAL”
git push

CHECKLIST DO ENGENHEIRO:
- [ ] PLAN
- [ ] PATCH (BLOCOS aplicados)
- [ ] TESTS a verde
- [ ] SELF-CHECK
- [ ] **RELATORIO.MD ATUALIZADO (OBRIGATÓRIO)**
````
