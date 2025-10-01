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

## 5. Fluxo de Trabalho
1. **Executar ordem** → atualizar `ordem/relatorio.md`
2. **Verificar luz verde** → `./ordem/verifica_luz_verde.sh`
3. **Se 🟡 PRONTO PARA GATEKEEPER** → `./ordem/gatekeeper.sh`
4. **Se 🟢 VERDE** → executar Git com convenção `[ORD-...]`

## 6. Convenções
- **Commits**: sempre `[ORD-YYYY-MM-DD-XXX] <resumo>`
- **Relatórios**: sempre atualizar `ordem/relatorio.md` com PLAN, PATCH, TESTS, SELF-CHECK
- **Pipeline**: usar geradores `make_chapter.sh`, `make_stage.sh`, `make_task.sh`

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
