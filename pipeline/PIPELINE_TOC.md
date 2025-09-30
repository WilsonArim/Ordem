# Pipeline - Índice Mestre

## Estrutura da Pipeline

A pipeline segue a hierarquia: **Capítulos → Etapas → Tarefas**

- **Capítulo (MXX)**: Módulo completo de funcionalidade
- **Etapa (EXX)**: Fase dentro de um capítulo
- **Tarefa (TXXX)**: Unidade mínima de trabalho

## Capítulos

### M01 - Exemplo de Módulo
- **Status**: TODO
- **Descrição**: Módulo de exemplo para demonstrar a estrutura da pipeline
- **Link**: [modulos/M01-exemplo/M01.md](modulos/M01-exemplo/M01.md)

#### Etapas do M01:
- **E01 - Exemplo de Etapa**
  - **Status**: TODO
  - **Link**: [modulos/M01-exemplo/etapas/E01-exemplo-etapa/E01.md](modulos/M01-exemplo/etapas/E01-exemplo-etapa/E01.md)
  
  ##### Tarefas da E01:
  - **T001 - Exemplo de Tarefa**
    - **Status**: TODO
    - **Link**: [modulos/M01-exemplo/etapas/E01-exemplo-etapa/tarefas/T001-exemplo/T001.md](modulos/M01-exemplo/etapas/E01-exemplo-etapa/tarefas/T001-exemplo/T001.md)

## Templates

- **Capítulo**: [_templates/CHAPTER.md](_templates/CHAPTER.md)
- **Etapa**: [_templates/STAGE.md](_templates/STAGE.md)
- **Tarefa**: [_templates/TASK.md](_templates/TASK.md)

## Estados Permitidos

- **TODO**: Não iniciado
- **EM_PROGRESSO**: Em desenvolvimento
- **EM_REVISAO**: Aguardando revisão
- **AGUARDA_GATEKEEPER**: Pronto para validação
- **DONE**: Concluído
