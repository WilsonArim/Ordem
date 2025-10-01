# MANUAL da Fábrica

## Papéis
- **Estado-Maior (GPT-5)**: escreve/ajusta SOPs, templates e pipeline.
- **Codex (VSCode/IDE)**: gere o dia-a-dia; decide luz verde via `verifica_luz_verde.sh`.
- **Engenheiro (Claude)**: executa ordens, aplica patches, escreve `relatorio.md`.
- **Operador (Tu)**: corre Gatekeeper e Git, quando autorizado.

## Linha de Montagem (Inviolável)
1. **Ordem** (ORDER_TEMPLATE) → entra em `fabrica/CLAUDE_QUEUE.md`.
2. **Execução** (Claude) → aplica PATCH e **atualiza `fabrica/relatorio.md`** (PLAN, PATCH, TESTS, SELF-CHECK).
3. **Inspeção** (Codex) → `./fabrica/verifica_luz_verde.sh`
   - `🟡 PRONTO PARA GATEKEEPER` (exit 10) → Operador: `./fabrica/gatekeeper.sh`
   - `🟢 VERDE` (exit 0) → Git permitido
4. **Gatekeeper** (Operador) → 7/7 PASSOU documentado no relatório.
5. **Git** (Operador) → commit com `[ORD-YYYY-MM-DD-XXX] …` e push.

## Pipeline (Capítulo → Etapa → Tarefa)
- Criar:
  - `./fabrica/make_chapter.sh M01 autenticacao`
  - `./fabrica/make_stage.sh   M01 E01 base-tokens`
  - `./fabrica/make_task.sh    M01 E01 T001 endpoint-login`
- Atualizar TOC: `./fabrica/update_pipeline_toc.sh` (também automático no pre-commit).
- **Regras**:
  - Em `pipeline/…/Mxx|Eyy|Tzzz.md`: `ID` é **código** (M/E/T), `STATUS` em {TODO, EM_PROGRESSO, EM_REVISAO, AGUARDA_GATEKEEPER, DONE}.
  - Em `fabrica/` e `treino_torre/`: `ID` é **data** `YYYY-MM-DD-XXX`.
  - Em `TASK.md`: secção **CRITÉRIOS** com **≥ 2** itens `- [ ]` / `- [x]` (obrigatório).

## Hooks (Disciplina Automática)
- `fabrica/hooks/pre-commit.sh` → atualiza TOC, valida SOP e **bloqueia commit** se falhar.
- Instalação:
  ```bash
  chmod +x fabrica/hooks/pre-commit.sh
  cp fabrica/hooks/pre-commit.sh .git/hooks/pre-commit
  ```

## Comandos Essenciais
- Validar SOP: `./fabrica/validate_sop.sh`
- Ver luz verde: `./fabrica/verifica_luz_verde.sh`
- Gatekeeper: `./fabrica/gatekeeper.sh`

## Commits (Convenção)
- Mensagem deve conter: `[ORD-YYYY-MM-DD-XXX] Descrição curta do patch`
