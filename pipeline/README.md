# Pipeline — Regras de Transição de STATUS

## Estados
- TODO → EM_PROGRESSO → EM_REVISAO → AGUARDA_GATEKEEPER → DONE

## Transições (evidências obrigatórias)
- **TODO → EM_PROGRESSO**: `relatorio.md` contém PLAN da tarefa.
- **EM_PROGRESSO → EM_REVISAO**: PATCH entregue + TESTS descritos no `relatorio.md`.
- **EM_REVISAO → AGUARDA_GATEKEEPER**: SELF-CHECK com itens `[x]` (critérios) no `relatorio.md`.
- **AGUARDA_GATEKEEPER → DONE**: `./ordem/gatekeeper.sh` 7/7 PASSOU + ordem explícita de Git (commit `[ORD-YYYY-MM-DD-XXX] ...`).

> A atualização do TOC é feita por `./ordem/update_pipeline_toc.sh` (ou tarefa VSCode "Pipeline: Atualizar TOC").

## INSTRUÇÕES RÁPIDAS
1. Criar capítulo: `./ordem/make_chapter.sh M01 autenticacao`
2. Criar etapa: `./ordem/make_stage.sh M01 E01 base-tokens`
3. Criar tarefa: `./ordem/make_task.sh M01 E01 T001 endpoint-login`
4. Atualizar TOC: `./ordem/update_pipeline_toc.sh`
