# Template de Capítulo/Módulo

## Campos Obrigatórios:
- **id**: Identificador único (M01, M02, etc.)
- **titulo**: Nome descritivo do módulo
- **descricao**: Resumo do que o módulo faz
- **status**: Estado atual (TODO, EM_PROGRESSO, EM_REVISAO, AGUARDA_GATEKEEPER, DONE)
- **dependencias**: Lista de módulos que devem ser concluídos antes
- **etapas**: Lista de etapas (E01, E02, etc.) que compõem o módulo

## Estados Permitidos:
- **TODO**: Não iniciado
- **EM_PROGRESSO**: Em desenvolvimento
- **EM_REVISAO**: Aguardando revisão
- **AGUARDA_GATEKEEPER**: Pronto para validação
- **DONE**: Concluído

---

# Capítulo [MXX] - [Título]

**ID**: MXX  
**Título**: [Nome do módulo]  
**Descrição**: [O que este módulo faz]  
**Status**: TODO  
**Dependências**: [Módulos que devem ser concluídos antes]  

## Etapas
- [ ] E01 - [Nome da etapa 1]
- [ ] E02 - [Nome da etapa 2]

## Critérios de Conclusão
- [ ] Todas as etapas concluídas
- [ ] Testes passando
- [ ] Gatekeeper 7/7 PASSOU
- [ ] Documentação atualizada

## Entregáveis
- [ ] Código funcional
- [ ] Testes unitários
- [ ] Documentação
- [ ] Aula na Torre (se aplicável)
