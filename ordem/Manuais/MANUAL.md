# MANUAL da Fábrica

## Papéis e Responsabilidades

- **Estado-Maior (GPT-5)**: escreve/ajusta SOPs, templates e pipeline.
- **IDE (Codex)**: lê pipeline, cria CLAUDE_QUEUE.md, dispara gatekeeper local, faz commit/push/PR (Draft), decide avanço.
- **Engenheiro (Claude)**: aplica patch, preenche `ordem/codex_claude/relatorio.md` (PLAN, PATCH, TESTS, SELF-CHECK). **Não faz commit**.
- **Operador (Tu)**: corre Gatekeeper e Git, quando autorizado pelo IDE.

## Fluxo Local (IDE decide Gatekeeping/Commit)

1. **IDE cria ordem** no `ordem/codex_claude/CLAUDE_QUEUE.md`.
2. **Claude implementa** e preenche `ordem/codex_claude/relatorio.md`.
3. **IDE corre** `./ordem/gatekeeper.sh`.
   - Se falhar: IDE usa wrappers (`npm run gatekeeper:*`), cria nova ordem para corrigir.
   - Se 7/7: IDE faz commit/push e abre PR Draft.

## Fluxo GitHub (CI Automático)

- **Em push/PR**: CI corre automático (`.github/workflows/ordem-ci.yml`).
- **Quando CI a verde** + relatório OK → IDE/Codex muda PR de Draft→Ready e faz merge.
- **Auditoria diária**: `.github/workflows/ordem-advanced.yml` corre às 03:00 UTC.

## Pipeline (Capítulo → Etapa → Tarefa)

- Criar:
  - `./ordem/make_chapter.sh M01 autenticacao`
  - `./ordem/make_stage.sh   M01 E01 base-tokens`
  - `./ordem/make_task.sh    M01 E01 T001 endpoint-login`
- Atualizar TOC: `./ordem/update_pipeline_toc.sh` (também automático no pre-commit).

## Gatekeeper Avançado (Monitorização Contínua)

- **Vigia automático**: `./ordem/gatekeeper_avancado/gatekeeper_avancado_loop.sh`
- **Verifica a cada 60s**: Conectividade, recursos, integridade
- **Logs automáticos**: `ordem/gatekeeper_avancado/gatekeeper_avancado_logs/`
- **Paragem**: CTRL+C ou `rm .gatekeeper_avancado.lock`
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
