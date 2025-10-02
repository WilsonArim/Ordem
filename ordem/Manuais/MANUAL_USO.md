# 📖 Manual de Uso da Ordem

## 1. Clonar a Ordem

```bash
git clone git@github.com:WilsonArim/Ordem.git
cd Ordem
```

## 2. Scripts principais (em ordem/)

- 🔍 **Validador SOP** → `./ordem/validate_sop.sh`
- 🟢 **Inspetor (Luz Verde)** → `./ordem/verifica_luz_verde.sh`
- 🛡️ **Gatekeeper (7/7 testes)** → `./ordem/gatekeeper.sh`
- 📚 **Atualizar TOC** → `./ordem/update_pipeline_toc.sh`

## 3. Git (apenas com Luz Verde)

```bash
git add .
git commit -m "[ORD-YYYY-MM-DD-XXX] Descrição curta"
git push
git push origin --tags
```

## 4. Estrutura de Pastas

- `ordem/` → SOPs, hooks, validadores, relatórios
- `pipeline/` → Capítulos, Etapas, Tarefas
- `treino_torre/` → Aulas para a Torre (Qwen)
- `.vscode/` → Tasks rápidas para IDE
- `.github/` → CI da Ordem

## 5. Fluxo de Trabalho (IDE decide Gatekeeping/Commit)

1. **IDE cria ordem** → `ordem/codex_claude/CLAUDE_QUEUE.md`
2. **Claude executa** → atualiza `ordem/codex_claude/relatorio.md`
3. **IDE verifica luz verde** → `./ordem/verifica_luz_verde.sh`
4. **IDE executa gatekeeper** → `./ordem/gatekeeper.sh` (se 🟡 PRONTO)
5. **IDE faz commit/push** → `[ORD-YYYY-MM-DD-XXX]` e abre PR Draft
6. **CI automático** → `.github/workflows/ordem-ci.yml` valida no GitHub

## 6. Convenções

- **Commits**: sempre `[ORD-YYYY-MM-DD-XXX] <resumo>` (feito pelo IDE)
- **Relatórios**: sempre atualizar `ordem/codex_claude/relatorio.md` com PLAN, PATCH, TESTS, SELF-CHECK (feito pelo Claude)
- **Pipeline**: usar geradores `make_chapter.sh`, `make_stage.sh`, `make_task.sh`
- **CI**: automático em push/PR via `.github/workflows/ordem-ci.yml`

## 7. Troubleshooting

- **SOP inválido**: verificar `./ordem/validate_sop.sh` para detalhes
- **Luz vermelha**: completar relatório e checklist
- **Gatekeeper falha**: corrigir problemas de qualidade (ESLint, Prettier, etc.)

## 8. 🔍 Wrappers individuais (debug rápido)

- Se algum teste falhar no `gatekeeper.sh`, podes correr cada wrapper individual para ver o erro completo:

```bash
npm run gatekeeper:eslint     # Verifica código JS/TS
npm run gatekeeper:prettier   # Verifica formatação
npm run gatekeeper:semgrep    # Scan de segurança
npm run gatekeeper:gitleaks   # Detecta segredos
npm run gatekeeper:npm-audit  # Vulnerabilidades npm
npm run gatekeeper:pip-audit  # Vulnerabilidades Python
npm run gatekeeper:sentry     # Verifica configuração Sentry
```

## 9. 👁️ Gatekeeper Avançado (vigia contínuo)

- O Gatekeeper Avançado é o vigia automático que corre SEMPRE em loop.
- Ele verifica a cada 60s se o projeto continua saudável.

### Como iniciar

```bash
./ordem/gatekeeper_avancado/gatekeeper_avancado_loop.sh
```

### Como saber que está a correr

- No terminal aparecem mensagens OK ✅ ou erros detectados.
- Também grava logs em `ordem/gatekeeper_avancado/gatekeeper_avancado_logs/`.

### Se detetar erros

1. Ler o log → identificar problema.
2. Corrigir o ficheiro afetado.
3. O Gatekeeper Avançado reexecuta sozinho após 30s.

### Como parar

- Pressionar CTRL + C no terminal onde está a correr.

## 10. 🔄 CI/CD (GitHub Actions)

### CI Automático (push/PR)

- **Ficheiro**: `.github/workflows/ordem-ci.yml`
- **Executa**: validate_sop.sh, verifica_luz_verde.sh, gatekeeper.sh
- **Quando**: em cada push e pull request
- **Artefactos**: relatórios e logs guardados automaticamente

### Auditoria Diária

- **Ficheiro**: `.github/workflows/ordem-advanced.yml`
- **Executa**: Gatekeeper Avançado (scan profundo)
- **Quando**: diariamente às 03:00 UTC + botão manual
- **Artefactos**: relatórios de auditoria guardados

### Verificar Status CI

- Ir ao GitHub → Actions → verificar se jobs estão a verde
- Se falhar: verificar logs e corrigir problemas localmente

### Branch Protection (CI Obrigatória)

- **Status**: Branch Protection ativo - merges só com CI verde (e review se configurado)
- **Verificar**: GitHub → Settings → Branches → Rules → main
- **Configurar**: Executar `./ordem/setup_branch_protection.sh`
- **Editar**: Settings → Branches → Rules → main → Edit
  - Contagens de review
  - Enforce for admins
  - Status checks obrigatórios
