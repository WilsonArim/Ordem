ID: [YYYY-MM-DD-XXX]
PRIORIDADE: [Alta|Média|Baixa]
STATUS: [TODO|EM_PROGRESSO|EM_REVISAO|AGUARDA_GATEKEEPER|DONE]

CONTEXTO:

- [ ] Por que é necessário?

AÇÃO:

- [ ] O que fazer exatamente? (1 linha)

DETALHES:

- [ ] Passos concretos
- [ ] Interfaces/Endpoints/Esquemas
- [ ] Notas de segurança/observabilidade, se houver

CRITÉRIOS (mensuráveis):

- [ ] [Critério 1]
- [ ] [Critério 2]
- [ ] Testes a verde (unit/E2E conforme aplicável)
- [ ] **RELATORIO.MD ATUALIZADO (PLAN, PATCH, TESTS, SELF-CHECK) — REGRA INVIOLÁVEL**

ENTREGÁVEIS DO ENGENHEIRO (Claude):

- PLAN: …
- PATCH (diff/resumo): …
- TESTS (resultados): …
- SELF-CHECK (porque cumpre critérios): …
- **RELATORIO.MD ATUALIZADO (OBRIGATÓRIO)**

HANDOFF (para Gatekeeper):

- Engenheiro concluiu e Estado-Maior aprovou?
- Se SIM → Operador corre `./ordem/gatekeeper.sh`

## GIT / CONTROLO DE VERSÃO

**Regra**: *"Só executar Git após 7/7 PASSOU e autorização do Estado-Maior."*

**Comando modelo**:
```bash
git add .
git commit -m "[ORD-YYYY-MM-DD-XXX] <resumo>"
git push
```

**Observação**: commits DEVEM começar por `[ORD-ID]`.

CHECKLIST DO ENGENHEIRO:

- [ ] PLAN escrito
- [ ] PATCH aplicado
- [ ] TESTS a verde
- [ ] SELF-CHECK preenchido
- [ ] **RELATORIO.MD ATUALIZADO**

⚠️ CLÁUSULA INVIOLÁVEL
Sem o `ordem/relatorio.md` atualizado, **a ordem é inválida** e não avança.

---

## CICLO DE RESPONSABILIDADES

- **Engenheiro (Claude)**: executa a ordem, aplica patch, corre testes e **atualiza `relatorio.md`**.
- **Estado-Maior (GPT-5)**: lê o `relatorio.md`, valida critérios, só então autoriza Gatekeeper.
- **Operador (tu)**: após autorização, corre `./ordem/gatekeeper.sh`; executa Git apenas após 7/7 PASSOU e ordem explícita.

➡️ **Se o `relatorio.md` não estiver completo e válido, a ordem NÃO segue para Gatekeeper.**
