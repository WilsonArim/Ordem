ID: 2025-09-30-013
PRIORIDADE: Alta
STATUS: DONE

CONTEXTO:
A Fábrica está funcional (pipeline, geradores, TOC, validador, inspetor). Falta “trancar a porta”:
1) TOC atualizar automaticamente no Git,
2) Validador reforçado: cada TASK precisa de ≥2 critérios,
3) Manual final do fluxo e papéis.

AÇÃO:
Blindar a Fábrica (hook + validação adicional) e criar MANUAL.md.

DETALHES (PASSOS CONCRETOS):
1) Criar `ordem/hooks/pre-commit.sh` com o BLOCO A, dar `chmod +x`, e instruir cópia para `.git/hooks/pre-commit`.
2) Atualizar `ordem/validate_sop.sh` adicionando a verificação “CRITÉRIOS ≥ 2” para **todas as TASK.md** (BLOCO B).
3) Criar `ordem/MANUAL.md` com o BLOCO C.
4) Executar:
   - `./ordem/update_pipeline_toc.sh` (uma vez)
   - `./ordem/validate_sop.sh` (deve sair 0)
5) Atualizar `ordem/relatorio.md` (PLAN, PATCH, TESTS, SELF-CHECK).

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
  - 0  → Operador faz Git (commit `[ORD-YYYY-MM-DD-XXX] …`)

## CICLO DE RESPONSABILIDADES
- Engenheiro (Claude): aplica BLOCO A+B+C, testa, documenta.
- Codex: decide luz verde via inspetor.
- Estado-Maior (GPT-5): supervisiona doutrina.
- Operador: Gatekeeper/Git apenas após luz verde.

# BLOCO A — ordem/hooks/pre-commit.sh
```bash
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
1. **Ordem** (ORDER_TEMPLATE) → entra em `ordem/CLAUDE_QUEUE.md`.
2. **Execução** (Claude) → aplica PATCH e **atualiza `ordem/relatorio.md`** (PLAN, PATCH, TESTS, SELF-CHECK).
3. **Inspeção** (Codex) → `./ordem/verifica_luz_verde.sh`
   - `🟡 PRONTO PARA GATEKEEPER` (exit 10) → Operador: `./ordem/gatekeeper.sh`
   - `🟢 VERDE` (exit 0) → Git permitido
4. **Gatekeeper** (Operador) → 7/7 PASSOU documentado no relatório.
5. **Git** (Operador) → commit com `[ORD-YYYY-MM-DD-XXX] …` e push.

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