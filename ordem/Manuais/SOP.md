# SOP

## Fluxo de Linha de Montagem (Inviolável)

A sequência completa de desenvolvimento disciplinado:

1. **Engenheiro** → `relatorio.md`
   - Executa a ordem
   - Aplica patch
   - Corre testes
   - Atualiza `relatorio.md` com PLAN, PATCH, TESTS, SELF-CHECK

2. **Estado-Maior** valida
   - Lê o `relatorio.md`
   - Valida critérios
   - Autoriza Gatekeeper

3. **Operador** corre Gatekeeper
   - Executa `./ordem/gatekeeper.sh`
   - Aguarda resultado 7/7 PASSOU

4. **Estado-Maior** valida 7/7
   - Confirma que todos os testes passaram
   - Autoriza Git

5. **Codex** verifica luz verde
   - Executa `verifica_luz_verde.sh`
   - Se VERDE → ordena Operador a executar Git
   - Se BLOQUEADO → devolve ao Engenheiro

6. **Operador** executa Git
   - `git add .`
   - `git commit -m "[ORD-YYYY-MM-DD-XXX] <resumo>"`
   - `git push`

7. **CI remoto**
   - GitHub Actions executa validações
   - Confirma disciplina no servidor

## Cláusulas de Ferro

### 1. Relatório Obrigatório
- **Sem `relatorio.md` válido** → ordem inválida
- **Sem `relatorio.md` atualizado** → ordem não avança

### 2. Gatekeeper Obrigatório
- **Sem 7/7 PASSOU** → **proibido Git**
- **Sem Gatekeeper** → ordem não concluída

### 3. Autorização Obrigatória
- **Sem ordem explícita do Estado-Maior** → **proibido Git**
- **Sem autorização** → não executar Git

### 4. Convenção de Commit
- **Mensagens de commit DEVEM iniciar com `[ORD-YYYY-MM-DD-XXX]`**
- **Formato**: `[ORD-2025-09-30-006] <resumo>`
- **Sem convenção** → commit inválido

## Estados de Ordem

- **TODO**: Não iniciado
- **EM_PROGRESSO**: Em desenvolvimento
- **EM_REVISAO**: Aguardando revisão
- **AGUARDA_GATEKEEPER**: Pronto para validação
- **DONE**: Concluído

## Validações Automáticas

### Pre-commit Hook
- Validação SOP
- Verificação de formatação (Prettier)
- Linting JavaScript/TypeScript (ESLint) - condicional

### GitHub Actions CI
- Setup Node.js 18+/20+ e Python 3.9+/3.11+
- Instalação de dependências
- Validação SOP
- Gatekeeper (7 testes)
- Security audits (npm + pip)
- Gitleaks (detecção de segredos)

## Regras de Disciplina

1. **Nenhuma ordem pode ser executada** sem:
   - Cláusula "RELATORIO.MD ATUALIZADO"
   - Secção "CICLO DE RESPONSABILIDADES"
   - Secção "GIT / CONTROLO DE VERSÃO"

2. **Nenhum commit pode ser feito** sem:
   - 7/7 PASSOU no Gatekeeper
   - Autorização explícita do Estado-Maior
   - Convenção de commit `[ORD-YYYY-MM-DD-XXX]`

3. **Nenhuma alteração pode ser feita** sem:
   - Validação SOP
   - Pre-commit hook
   - CI remoto

## Papéis e Responsabilidades

### Comandante
- Define estratégia geral
- Aprova mudanças de doutrina
- Supervisiona operações críticas

### Estado-Maior (GPT-5)
- Estratégia apenas
- Valida relatórios complexos
- Autoriza mudanças de processo

### Codex (Inspetor/Operador Diário)
- **Delegado para luz verde** mediante `verifica_luz_verde.sh`
- Gere operação diária sem depender do Estado-Maior
- Executa `verifica_luz_verde.sh` após cada ordem
- Ordena Operador a correr Gatekeeper/Git conforme fluxo
- Registra bloqueios no `relatorio.md`

### Engenheiro (Claude)
- Executa ordens
- Aplica patches
- Corre testes
- Atualiza `relatorio.md`

### Operador (Tu)
- Corre Gatekeeper após autorização do Codex
- Executa Git apenas após 7/7 PASSOU e ordem explícita do Codex
- Segue convenções de commit

## Violações e Consequências

- **Ordem sem relatório** → Rejeitada automaticamente
- **Git sem 7/7 PASSOU** → Commit bloqueado
- **Git sem autorização** → Commit bloqueado
- **Commit sem convenção** → Commit bloqueado
- **Alteração sem validação** → Commit bloqueado
