# Fábrica de Desenvolvimento Disciplinado

Sistema de desenvolvimento com disciplina automática, validação SOP e Gatekeeper.

## Estrutura

- `ordem/` - Scripts e configurações da Fábrica
- `treino_torre/` - Aulas para treino da Torre (Qwen)
- `pipeline/` - Modelo doutrinado da pipeline (Capítulos → Etapas → Tarefas)

## Scripts Principais

### Validação SOP

```bash
./ordem/validate_sop.sh
```

Valida todas as regras de disciplina da Fábrica.

### Gatekeeper

```bash
./ordem/gatekeeper.sh
```

Executa os 7 testes de qualidade: ESLint, Prettier, Semgrep, Gitleaks, npm-audit, pip-audit, Sentry.

### Scripts de Debug

```bash
npm run gatekeeper:eslint
npm run gatekeeper:prettier
npm run gatekeeper:semgrep
npm run gatekeeper:gitleaks
npm run gatekeeper:npm-audit
npm run gatekeeper:pip-audit
npm run gatekeeper:sentry
```

## Hooks Git

### Pre-commit Hook

O hook pre-commit executa automaticamente:

1. Validação SOP
2. Verificação de formatação (Prettier)
3. Linting JavaScript/TypeScript (ESLint) - se houver ficheiros JS/TS

**Instalação:**

```bash
cp ordem/hooks/pre-commit.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

## CI/CD

### GitHub Actions

O workflow `.github/workflows/fabrica-ci.yml` executa em:

- Push para `main` ou `develop`
- Pull requests para `main`

**Validações:**

- SOP validation
- Gatekeeper (7 testes)
- Security audits (npm + pip)
- Gitleaks (detecção de segredos)

## Proteção de Branch

### Configuração Recomendada para `main`:

1. **Branch Protection Rules:**
   - Require a pull request before merging
   - Require status checks to pass before merging
   - Require branches to be up to date before merging
   - Restrict pushes that create files larger than 100MB

2. **Required Status Checks:**
   - `validate (18.x, 3.9)` - Validação principal
   - `security` - Auditorias de segurança

3. **Restrictions:**
   - Restrict pushes to matching branches
   - Allow force pushes: ❌
   - Allow deletions: ❌

### Configuração no GitHub:

1. Vá para Settings → Branches
2. Add rule para `main`
3. Configure as regras acima
4. Save changes

## Convenções

### Mensagens de Commit

```
[ORD-YYYY-MM-DD-XXX] <resumo>
```

**Exemplos:**

- `[ORD-2025-09-30-004B] Git init + SOP restore`
- `[ORD-2025-09-30-005] Implementar hooks e CI`
- `[ORD-2025-09-30-006] Integrar Git na doutrina`

### Quando Executar Git

**Após 7/7 PASSOU e luz verde do Estado-Maior, o Operador executa Git com a convenção de commit.**

**Sequência obrigatória:**
1. Engenheiro → `relatorio.md`
2. Estado-Maior valida
3. Operador corre Gatekeeper
4. Estado-Maior valida 7/7
5. **Operador executa Git** (com convenção de commit)
6. CI remoto

### Estados de Ordem

- `TODO` - Não iniciado
- `EM_PROGRESSO` - Em desenvolvimento
- `EM_REVISAO` - Aguardando revisão
- `AGUARDA_GATEKEEPER` - Pronto para validação
- `DONE` - Concluído

## Regras Invioláveis

1. **RELATORIO.MD ATUALIZADO** - Obrigatório em todas as ordens
2. **CICLO DE RESPONSABILIDADES** - Secção obrigatória
3. **Gatekeeper 7/7 PASSOU** - Antes de marcar DONE
4. **SOP válido** - Sempre antes de commit

## Como o Codex gere o dia-a-dia

### Papel do Codex
**Codex é o Inspetor/Operador Diário** - delegado para luz verde mediante `verifica_luz_verde.sh`.

### Operação Diária
1. **Ler ordens** em `CLAUDE_QUEUE.md`
2. **Executar inspetor** após cada ordem: `./ordem/verifica_luz_verde.sh`
3. **Decidir próxima ação** baseado no código de saída:
   - **Exit 0 (VERDE)**: Ordenar Git se Gatekeeper passou
   - **Exit 10 (PRONTO PARA GATEKEEPER)**: Ordenar Operador a correr Gatekeeper
   - **Exit 1 (BLOQUEADO)**: Devolver ao Engenheiro

### Comandos Essenciais
```bash
# Inspetor principal
./ordem/verifica_luz_verde.sh

# Validação SOP
./ordem/validate_sop.sh

# Gatekeeper (Operador)
./ordem/gatekeeper.sh
```

### VSCode Tasks
Use `Ctrl+Shift+P` → "Tasks: Run Task":
- **SOP: Validar** - Valida regras SOP
- **Fábrica: Gatekeeper (7/7)** - Executa testes de qualidade
- **Fábrica: Verificar luz verde (Inspetor)** - Verifica se está pronto para prosseguir

### Manual Completo
Consulte `ordem/CODEX_ONBOARDING.md` para instruções detalhadas.

## Troubleshooting

### Pre-commit Hook Falha

```bash
# Verificar se está instalado
ls -la .git/hooks/pre-commit

# Reinstalar se necessário
cp ordem/hooks/pre-commit.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

### CI Falha

1. Verificar logs no GitHub Actions
2. Executar localmente: `./ordem/gatekeeper.sh`
3. Corrigir problemas e fazer novo commit

### ESLint Ignorado

ESLint só executa se houver ficheiros `.js`, `.ts`, `.jsx`, `.tsx`. Se não houver, é ignorado automaticamente.

### Inspetor Codex Falha

```bash
# Verificar estado detalhado
./ordem/verifica_luz_verde.sh
echo "Exit code: $?"

# Códigos de saída:
# 0 = VERDE (pronto para Git)
# 10 = PRONTO PARA GATEKEEPER
# 1 = BLOQUEADO (corrigir problemas)
```
