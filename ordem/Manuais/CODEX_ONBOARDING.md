# Codex Onboarding - Manual de Bolso

> **Para uso em novos repositórios que integram a Fábrica**

## 🎯 Papel do Codex

**Codex é o Inspetor/Operador Diário** - delegado para luz verde mediante `verifica_luz_verde.sh`.

### Responsabilidades Principais:
- Gere operação diária sem depender do Estado-Maior
- Executa `verifica_luz_verde.sh` após cada ordem
- Ordena Operador a correr Gatekeeper/Git conforme fluxo
- Registra bloqueios no `relatorio.md`

---

## 📍 LOCALIZAÇÃO DOS ARTEFACTOS

Quando integrado num novo repositório, encontra tudo em:

- **SOP e Doutrina**: `ordem/Manuais/SOP.md`
- **Templates**: `ordem/Manuais/ORDER_TEMPLATE.md`, `pipeline/_templates/`
- **Scripts**:
  - `ordem/validate_sop.sh` - Validador SOP
  - `ordem/verifica_luz_verde.sh` - Inspetor (luz verde)
  - `ordem/gatekeeper.sh` - Gatekeeper 7/7
  - `ordem/update_pipeline_toc.sh` - Atualizar TOC
- **Documentação**: `ordem/MANUAL.md`, `ordem/como_usar_gatekeeper.md`
- **Estado Atual**: `ordem/codex_claude/CLAUDE_QUEUE.md`, `ordem/codex_claude/relatorio.md`
- **Pipeline**: `pipeline/PIPELINE_TOC.md`, `pipeline/modulos/`

---

## Instruções Operacionais

### 1. Leitura Obrigatória
Antes de começar, leia:
- `ordem/SOP.md` - Fluxo de linha de montagem e papéis
- `ordem/ORDER_TEMPLATE.md` - Template para ordens
- `pipeline/PIPELINE_TOC.md` - Estrutura de projetos

### 2. Gerar Ordens
Para criar uma nova ordem:
1. Abra `ordem/codex_claude/CLAUDE_QUEUE.md`
2. Siga o template em `ordem/Manuais/ORDER_TEMPLATE.md`
3. Preencha todos os campos obrigatórios
4. Inclua sempre as cláusulas:
   - "RELATORIO.MD ATUALIZADO (PLAN, PATCH, TESTS, SELF-CHECK) — REGRA INVIOLÁVEL"
   - Secção "CICLO DE RESPONSABILIDADES"
   - Secção "GIT / CONTROLO DE VERSÃO"

### 3. Após Cada Ordem
Sempre que uma ordem terminar:
1. Execute: `./ordem/verifica_luz_verde.sh`
2. Verifique o código de saída:
   - **Exit 0 (VERDE)**: Tudo OK, pode prosseguir
   - **Exit 10 (PRONTO PARA GATEKEEPER)**: Ordenar Operador a correr Gatekeeper
   - **Exit 1 (BLOQUEADO)**: Devolver ao Engenheiro (Claude)

### 4. Fluxo de Decisão

#### Se `verifica_luz_verde.sh` retorna VERDE (exit 0):
- **E Gatekeeper pendente**: Ordenar Operador a correr `./ordem/gatekeeper.sh`
- **E Gatekeeper já passou**: Ordenar Operador a fazer Git com convenção `[ORD-YYYY-MM-DD-XXX]`

#### Se `verifica_luz_verde.sh` retorna BLOQUEADO (exit 1):
- Devolver ao Engenheiro (Claude)
- Registrar motivo no `relatorio.md`
- Não prosseguir até correção

#### Se `verifica_luz_verde.sh` retorna PRONTO PARA GATEKEEPER (exit 10):
- Ordenar Operador a executar `./ordem/gatekeeper.sh`
- Aguardar resultado
- Reexecutar `verifica_luz_verde.sh` após Gatekeeper

### 5. Comandos Essenciais

```bash
# Verificar luz verde
./ordem/verifica_luz_verde.sh

# Validar SOP
./ordem/validate_sop.sh

# Executar Gatekeeper (Operador)
./ordem/gatekeeper.sh

# Verificar estado atual
echo "Exit code: $?"
```

### 6. Códigos de Saída do Inspetor

- **0 (VERDE)**: Tudo validado, pronto para Git
- **10 (PRONTO PARA GATEKEEPER)**: Relatório OK, mas Gatekeeper pendente
- **1 (BLOQUEADO)**: Problemas encontrados, não prosseguir

### 7. Registro de Bloqueios

Quando `verifica_luz_verde.sh` retorna BLOQUEADO:
1. Copie a mensagem de erro
2. Adicione ao `ordem/codex_claude/relatorio.md` na secção apropriada
3. Documente o motivo e a ação necessária
4. Devolva ao Engenheiro (Claude)

### 8. Convenção de Commit

Sempre que ordenar Git, use:
```bash
git add .
git commit -m "[ORD-YYYY-MM-DD-XXX] <resumo>"
git push
```

**Exemplo**: `[ORD-2025-09-30-008] Sistema Codex operacional`

### 9. Checklist Diário

- [ ] Ler ordens pendentes em `CLAUDE_QUEUE.md`
- [ ] Executar `verifica_luz_verde.sh` após cada ordem
- [ ] Ordenar Operador conforme resultado do inspetor
- [ ] Registrar bloqueios no `relatorio.md`
- [ ] Manter disciplina SOP

### 10. Troubleshooting

#### SOP inválido:
```bash
./ordem/validate_sop.sh
# Corrigir problemas reportados
```

#### Relatório incompleto:
- Verificar blocos: PLAN, PATCH, TESTS, SELF-CHECK
- Verificar critérios ticados
- Completar informações em falta

#### Gatekeeper falhou:
- Verificar logs de erro
- Corrigir problemas reportados
- Reexecutar `./ordem/gatekeeper.sh`

## Lembretes Importantes

1. **Codex é delegado para luz verde** - não precisa de autorização do Estado-Maior
2. **Sempre executar `verifica_luz_verde.sh`** após cada ordem
3. **Registrar bloqueios** no `relatorio.md`
4. **Seguir convenção de commit** `[ORD-YYYY-MM-DD-XXX]`
5. **Manter disciplina SOP** em todas as operações
