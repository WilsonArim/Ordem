# 📦 INSTRUÇÕES DE INTEGRAÇÃO — Fábrica v1.0.0

## 🎯 Objetivo
Integrar a Fábrica em qualquer repositório (ex.: Viriato) mantendo disciplina (hooks, validador, inspetor, pipeline-base).

---

## 📋 PRÉ-REQUISITOS

### Software Necessário
- Git
- Node.js (npm)
- Python 3 + pip
- Bash shell

### Ferramentas de Qualidade
```bash
# Node.js
npm install --save-dev eslint prettier

# Python
pip install semgrep
pipx install pip-audit gitleaks

# Sentry (opcional)
npm install @sentry/node
```

---

## 🚀 PASSO-A-PASSO DE INTEGRAÇÃO

### 1️⃣ **Extrair Pacote**
```bash
# Extrair Fabrica-Pacote.zip na raiz do seu repositório
unzip Fabrica-Pacote.zip -d /caminho/do/seu/repo/
cd /caminho/do/seu/repo/
```

Estrutura resultante:
```
seu-repo/
├── fabrica/
│   ├── hooks/
│   ├── validate_sop.sh
│   ├── verifica_luz_verde.sh
│   ├── gatekeeper.sh
│   ├── MANUAL.md
│   ├── ORDER_TEMPLATE.md
│   ├── CLAUDE_QUEUE.md
│   ├── relatorio.md
│   └── CODEX_ONBOARDING.md
├── pipeline/
│   ├── _templates/
│   └── modulos/M01-exemplo/
└── .vscode/
    └── tasks.json
```

### 2️⃣ **Instalar Hook Pre-Commit**
```bash
chmod +x fabrica/hooks/pre-commit.sh
chmod +x fabrica/validate_sop.sh
chmod +x fabrica/verifica_luz_verde.sh
chmod +x fabrica/gatekeeper.sh

# Instalar hook
cp fabrica/hooks/pre-commit.sh .git/hooks/pre-commit
```

### 3️⃣ **Validar Instalação**
```bash
# Validar SOP
./fabrica/validate_sop.sh

# Verificar luz verde
./fabrica/verifica_luz_verde.sh
```

**Saídas esperadas**:
- ✅ SOP válido: todas as verificações passaram.
- 🟡 PRONTO PARA GATEKEEPER (se ainda não executou Gatekeeper)
- 🟢 VERDE (se tudo completo)

### 4️⃣ **Configurar package.json**
Adicionar scripts de Gatekeeper ao `package.json`:

```json
{
  "scripts": {
    "gatekeeper": "./fabrica/gatekeeper.sh",
    "gatekeeper:eslint": "eslint .",
    "gatekeeper:prettier": "prettier --check .",
    "gatekeeper:semgrep": "semgrep --config auto .",
    "gatekeeper:gitleaks": "gitleaks detect --source . --verbose",
    "gatekeeper:npm-audit": "npm audit --audit-level=moderate",
    "gatekeeper:pip-audit": "~/.local/bin/pip-audit -r requirements.txt || true",
    "gatekeeper:sentry": "grep -q SENTRY_DSN env.example && echo '✅ Sentry DSN presente' || echo '⚠️  Sentry DSN ausente'"
  }
}
```

### 5️⃣ **Criar Ficheiros Auxiliares**
```bash
# requirements.txt (Python)
touch requirements.txt

# env.example (Sentry)
echo "SENTRY_DSN=your-sentry-dsn-here" > env.example
```

---

## 🧭 FLUXO DE TRABALHO

### Para o Codex (AI Assistant)
1. **Ler onboarding**: `fabrica/CODEX_ONBOARDING.md`
2. **Ler SOP**: `fabrica/SOP.md`
3. **Receber ordem**: `fabrica/CLAUDE_QUEUE.md`
4. **Executar trabalho**: Aplicar patch, atualizar `fabrica/relatorio.md`
5. **Verificar luz verde**: `./fabrica/verifica_luz_verde.sh`
   - 🟡 Exit 10 → Avisar Operador para Gatekeeper
   - 🟢 Exit 0 → Avisar Operador para Git

### Para o Operador (Humano)
1. **Após 🟡**: Executar `./fabrica/gatekeeper.sh`
2. **Após 🟢**: Executar Git:
   ```bash
   git add .
   git commit -m "[ORD-YYYY-MM-DD-XXX] Descrição"
   git push
   ```

---

## 🔧 COMANDOS ESSENCIAIS

### VSCode Tasks (Ctrl+Shift+P → "Run Task")
- **SOP: Validar** → `./fabrica/validate_sop.sh`
- **Fábrica: Gatekeeper (7/7)** → `./fabrica/gatekeeper.sh`
- **Fábrica: Verificar luz verde** → `./fabrica/verifica_luz_verde.sh`
- **Pipeline: Atualizar TOC** → `./fabrica/update_pipeline_toc.sh`

### Terminal
```bash
# Validar tudo
./fabrica/validate_sop.sh

# Ver estado
./fabrica/verifica_luz_verde.sh

# Gatekeeper completo
./fabrica/gatekeeper.sh

# Criar pipeline
./fabrica/make_chapter.sh M02 autenticacao
./fabrica/make_stage.sh M02 E01 base-tokens
./fabrica/make_task.sh M02 E01 T001 endpoint-login

# Atualizar TOC
./fabrica/update_pipeline_toc.sh
```

---

## ⚠️ REGRAS IMPORTANTES

### IDs e Formatos
- **fabrica/** e **treino_torre/**: `ID: YYYY-MM-DD-XXX` (data)
- **pipeline/**: `ID: Mxx`, `ID: Eyy`, `ID: Txxx` (código)
- **TASK.md**: Secção `## CRITÉRIOS` com **≥ 2** checklists obrigatórios

### STATUS Permitidos
- Pipeline: `TODO`, `EM_PROGRESSO`, `EM_REVISAO`, `AGUARDA_GATEKEEPER`, `DONE`
- Ordens: `TODO`, `DONE`

### Commits
- Formato: `[ORD-YYYY-MM-DD-XXX] Descrição curta`
- **Só após luz verde** (🟢)

---

## 🆘 TROUBLESHOOTING

### Hook bloqueia commit
```bash
# Ver erro específico
./fabrica/validate_sop.sh

# Bypass emergencial (USE COM CUIDADO)
SKIP_SOP=1 git commit -m "..."
```

### Gatekeeper falha
```bash
# Testar individualmente
npm run gatekeeper:eslint
npm run gatekeeper:prettier
npm run gatekeeper:semgrep
```

### Validador não reconhece CRITÉRIOS
- Verificar se secção é exatamente `## CRITÉRIOS` (maiúsculas)
- Verificar se tem ≥ 2 checklists: `- [ ] ...` ou `- [x] ...`

---

## 📚 DOCUMENTAÇÃO COMPLETA

- **Manual da Fábrica**: `fabrica/MANUAL.md`
- **SOP**: `fabrica/SOP.md`
- **Onboarding Codex**: `fabrica/CODEX_ONBOARDING.md`
- **Como usar Gatekeeper**: `fabrica/como_usar_gatekeeper.md`

---

## ✅ CHECKLIST DE INTEGRAÇÃO

- [ ] Pacote extraído na raiz do repositório
- [ ] Hook pre-commit instalado (`cp fabrica/hooks/pre-commit.sh .git/hooks/pre-commit`)
- [ ] Scripts executáveis (`chmod +x fabrica/*.sh`)
- [ ] `package.json` configurado com scripts Gatekeeper
- [ ] `requirements.txt` criado
- [ ] `env.example` criado com `SENTRY_DSN`
- [ ] `./fabrica/validate_sop.sh` a verde
- [ ] `./fabrica/verifica_luz_verde.sh` executado com sucesso
- [ ] VSCode tasks funcionais

---

**🎉 Fábrica integrada com sucesso! Disciplina garantida.**

