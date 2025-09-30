ID: 2025-09-30-004
PRIORIDADE: Alta
STATUS: TODO

CONTEXTO:
- A Ordem 003 criou a estrutura da pipeline (PIPELINE_TOC.md, CHAPTER.md, STAGE.md, TASK.md).
- Precisamos garantir disciplina automática: nenhuma parte da pipeline pode existir fora da doutrina definida.

AÇÃO:
Expandir o script `fabrica/validate_sop.sh` para validar também a pipeline (CHAPTER, STAGE, TASK, TOC).

DETALHES:
1. Validar **CHAPTER.md**:
   - Deve conter: ID, Título, STATUS.
   - STATUS deve ser um dos: TODO, EM_PROGRESSO, EM_REVISAO, AGUARDA_GATEKEEPER, DONE.
2. Validar **STAGE.md**:
   - Deve conter: ID, Ligação ao capítulo pai (capitulo: Mxx).
   - Deve ter STATUS válido (como acima).
3. Validar **TASK.md**:
   - Deve conter: ID, PRIORIDADE, STATUS.
   - Deve conter pelo menos 2 CRITÉRIOS (com checkbox).
   - Deve conter CHECKLIST (PLAN, PATCH, TESTS, SELF-CHECK, RELATORIO.MD ATUALIZADO).
   - STATUS deve ser válido.
4. Validar **PIPELINE_TOC.md**:
   - Todos os links devem apontar para ficheiros existentes no repositório.
   - Estrutura hierárquica correta: Capítulo → Etapas → Tarefas.
5. Adicionar mensagens claras de erro, por ex.:
   - “❌ CHAPTER sem campo STATUS em pipeline/modulos/M01/M01.md”
   - “❌ TASK 2025-10-01-002 sem CHECKLIST obrigatório”
6. Ignorar os ficheiros dentro de `/pipeline/_templates` (são apenas modelos).
7. Manter as validações já existentes (ordens, relatorio.md, aulas da Torre).

CRITÉRIOS (mensuráveis):
- [ ] `validate_sop.sh` atualizado e funcional.
- [ ] CHAPTER.md, STAGE.md, TASK.md validados com campos obrigatórios.
- [ ] PIPELINE_TOC.md validado com links reais.
- [ ] Templates em `_templates` ignorados.
- [ ] Testes a verde (executar o validador sem erros na pipeline atual).
- [ ] **RELATORIO.MD ATUALIZADO (PLAN, PATCH, TESTS, SELF-CHECK) — REGRA INVIOLÁVEL**

ENTREGÁVEIS DO ENGENHEIRO (Claude):
- PLAN: passos concretos para expandir o validador.
- PATCH: alterações feitas no `validate_sop.sh`.
- TESTS: resultado da execução do validador (sem erros na pipeline de exemplo).
- SELF-CHECK: confirmação de que os critérios foram cumpridos.
- **RELATORIO.MD ATUALIZADO (OBRIGATÓRIO)**

HANDOFF (para Gatekeeper):
- Engenheiro concluiu e Estado-Maior aprovou?
- Se SIM → Operador corre `./fabrica/gatekeeper.sh`

CHECKLIST DO ENGENHEIRO:
- [ ] PLAN escrito
- [ ] PATCH aplicado
- [ ] TESTS a verde
- [ ] SELF-CHECK preenchido
- [ ] **RELATORIO.MD ATUALIZADO**

⚠️ CLÁUSULA INVIOLÁVEL
Sem o `fabrica/relatorio.md` atualizado, a ordem é inválida e não avança.

## CICLO DE RESPONSABILIDADES
- **Engenheiro (Claude)**: expande o validador, garante testes a verde, atualiza `relatorio.md`.
- **Estado-Maior (GPT-5)**: valida o relatório e autoriza Gatekeeper.
- **Operador (tu)**: após autorização, corre `./fabrica/gatekeeper.sh`.