# Como usar o Gatekeeper

1. Para correr todos os testes:
   ./fabrica/gatekeeper.sh

2. Se todos passarem:
   ✅ GATEKEEPER: TODOS OS TESTES PASSARAM

3. Se falhar, o script para no teste errado e mostra o motivo.

4. Para ver detalhes completos, corre os debug scripts:
   npm run gatekeeper:eslint
   npm run gatekeeper:prettier
   npm run gatekeeper:semgrep
   npm run gatekeeper:gitleaks
   npm run gatekeeper:npm-audit
   npm run gatekeeper:pip-audit
   npm run gatekeeper:sentry

## Após 7/7 PASSOU:
1) O Estado-Maior marca DONE no diário.
2) Executar:
   ./fabrica/make_aula.sh <ID> <Mxx> <Eyy> <Tzzz> <slug> "<tags>"
3) Inserir o link da aula no /treino_torre/TOC.md e no diário.
