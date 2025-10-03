📑 ORDER_TEMPLATE.md (v2 – fluxo atualizado)

ID: [YYYY-MM-DD-XXX]  
PRIORIDADE: [Alta|Média|Baixa]  
STATUS: [TODO|EM_PROGRESSO|EM_REVISAO|AGUARDA_GATEKEEPER|DONE]  

---

## CONTEXTO
- [ ] Por que é necessário?

## AÇÃO
- [ ] O que fazer exatamente? (1 linha)

## DETALHES
- [ ] Passos concretos
- [ ] Interfaces/Endpoints/Esquemas
- [ ] Notas de segurança/observabilidade, se houver

## CRITÉRIOS (mensuráveis)
- [ ] [Critério 1]
- [ ] [Critério 2]
- [ ] Testes a verde (unit/E2E conforme aplicável)
- [ ] **RELATORIO.MD ATUALIZADO (PLAN, PATCH, TESTS, SELF-CHECK) — REGRA INVIOLÁVEL**

---

## ENTREGÁVEIS DO ENGENHEIRO (Claude)
- PLAN: …
- PATCH (diff/resumo): …
- TESTS (resultados): …
- SELF-CHECK (porque cumpre critérios): …
- **RELATORIO.MD ATUALIZADO (OBRIGATÓRIO)**

---

## CICLO DE RESPONSABILIDADES
- **Engenheiro (Claude)**: executa a ordem, aplica patch, corre testes e **atualiza `relatorio.md`**.  
- **Codex (IDE)**:  
  1. Valida o `relatorio.md` contra o template  
  2. Corre `./ordem/gatekeeper.sh` (7/7)  
  3. Se PASSOU → marca a pipeline (task = DONE)  
  4. Atualiza o diário de bordo  
  5. Corre `./ordem/validate_sop.sh`  
  6. Se tudo verde → fecha oficialmente a fase  
- **Estado-Maior (GPT-5)**: supervisiona doutrina, mantém SOPs e templates atualizados.  
- **Operador (Tu)**: só executa **Git** (após luz verde do Codex).

---

## GIT / CONTROLO DE VERSÃO
**Regra**: _"Só executar Git após 7/7 PASSOU e autorização do Codex."_  

**Comando modelo:**
```bash
git add .
git commit -m "[ORD-YYYY-MM-DD-XXX] <resumo>"
git push

Observação: commits DEVEM começar por [ORD-ID].

⸻

CHECKLIST DO ENGENHEIRO
	•	PLAN escrito
	•	PATCH aplicado
	•	TESTS a verde
	•	SELF-CHECK preenchido
	•	RELATORIO.MD ATUALIZADO

⸻

⚠️ CLÁUSULA INVIOLÁVEL
Sem o ordem/relatorio.md atualizado, a ordem é inválida e não avança.

---
