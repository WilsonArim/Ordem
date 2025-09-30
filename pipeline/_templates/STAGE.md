# Template de Etapa

## Campos Obrigatórios:
- **id**: Identificador único (E01, E02, etc.)
- **titulo**: Nome descritivo da etapa
- **descricao**: Resumo do que a etapa faz
- **status**: Estado atual (TODO, EM_PROGRESSO, EM_REVISAO, AGUARDA_GATEKEEPER, DONE)
- **dependencias**: Lista de etapas que devem ser concluídas antes
- **tarefas**: Lista de tarefas (T001, T002, etc.) que compõem a etapa

## Estados Permitidos:
- **TODO**: Não iniciado
- **EM_PROGRESSO**: Em desenvolvimento
- **EM_REVISAO**: Aguardando revisão
- **AGUARDA_GATEKEEPER**: Pronto para validação
- **DONE**: Concluído

---

# Etapa [EXX] - [Título]

**ID**: EXX  
**Título**: [Nome da etapa]  
**Descrição**: [O que esta etapa faz]  
**Status**: TODO  
**Dependências**: [Etapas que devem ser concluídas antes]  

## Tarefas
- [ ] T001 - [Nome da tarefa 1]
- [ ] T002 - [Nome da tarefa 2]

## Critérios de Conclusão
- [ ] Todas as tarefas concluídas
- [ ] Testes passando
- [ ] Gatekeeper 7/7 PASSOU
- [ ] Documentação atualizada

## Entregáveis
- [ ] Funcionalidade implementada
- [ ] Testes unitários
- [ ] Documentação
- [ ] Aula na Torre (se aplicável)
