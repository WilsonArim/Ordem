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
  ```

## Comandos Essenciais
- Validar SOP: `./ordem/validate_sop.sh`
- Ver luz verde: `./ordem/verifica_luz_verde.sh`
- Gatekeeper: `./ordem/gatekeeper.sh`

## Commits (Convenção)
- Mensagem deve conter: `[ORD-YYYY-MM-DD-XXX] Descrição curta do patch`
