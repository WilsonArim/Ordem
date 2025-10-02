# 🔄 INTEGRAÇÃO GATEKEEPER AVANÇADO COM PROJETO ORDEM

## 📁 Estrutura proposta para o projeto Ordem

```
ordem/
├── gatekeeper_avancado/
│   ├── gatekeeper_avancado_loop.sh          # Script principal extraído
│   ├── GATEKEEPER_AVANCADO.md        # Manual de utilização
│   ├── .gatekeeper_avancado.lock           # Lockfile (criado automaticamente)
│   └── gatekeeper_avancado_logs/           # Diretório de logs
│       └── gatekeeper_avancado_YYYYMMDD.log # Log diário
├── .vscode/
│   └── tasks.json               # Tarefas VSCode
└── package.json                 # Scripts npm (se aplicável)
```

## 🎯 Tarefas VSCode propostas

### Ficheiro: `.vscode/tasks.json`

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Ordem: Gatekeeper Avançado contínuo",
      "type": "shell",
      "command": "./ordem/gatekeeper_avancado/gatekeeper_avancado_loop.sh",
      "group": "build",
      "presentation": {
        "echo": true,
        "reveal": "always",
        "focus": false,
        "panel": "new",
        "showReuseMessage": true,
        "clear": false
      },
      "options": {
        "cwd": "${workspaceFolder}"
      },
      "problemMatcher": [],
      "runOptions": {
        "runOn": "folderOpen"
      }
    },
    {
      "label": "Ordem: Parar Gatekeeper Avançado",
      "type": "shell",
      "command": "rm -f ./ordem/gatekeeper_avancado/.gatekeeper_avancado.lock",
      "group": "build",
      "presentation": {
        "echo": true,
        "reveal": "always",
        "focus": false,
        "panel": "shared",
        "showReuseMessage": true,
        "clear": false
      },
      "options": {
        "cwd": "${workspaceFolder}"
      },
      "problemMatcher": []
    },
    {
      "label": "Ordem: Ver logs Gatekeeper Avançado",
      "type": "shell",
      "command": "tail -f ./ordem/gatekeeper_avancado/gatekeeper_avancado_logs/gatekeeper_avancado_$(date +%Y%m%d).log",
      "group": "build",
      "presentation": {
        "echo": true,
        "reveal": "always",
        "focus": false,
        "panel": "new",
        "showReuseMessage": true,
        "clear": false
      },
      "options": {
        "cwd": "${workspaceFolder}"
      },
      "problemMatcher": []
    }
  ]
}
```

## 📦 Scripts npm propostos (se aplicável)

### Ficheiro: `package.json` (adicionar à secção scripts)

```json
{
  "scripts": {
    "gatekeeper-avancado": "./ordem/gatekeeper_avancado/gatekeeper_avancado_loop.sh",
    "gatekeeper-avancado:stop": "rm -f ./ordem/gatekeeper_avancado/.gatekeeper_avancado.lock",
    "gatekeeper-avancado:logs": "tail -f ./ordem/gatekeeper_avancado/gatekeeper_avancado_logs/gatekeeper_avancado_$(date +%Y%m%d).log",
    "gatekeeper-avancado:install": "chmod +x ./ordem/gatekeeper_avancado/gatekeeper_avancado_loop.sh"
  }
}
```

## 🚀 Comandos de arranque/paragem

### Arranque

```bash
# Método 1: Via npm
npm run gatekeeper-avancado

# Método 2: Via VSCode
# Ctrl+Shift+P -> "Tasks: Run Task" -> "Ordem: Gatekeeper Avançado contínuo"

# Método 3: Direto
cd ordem/gatekeeper_avancado
./gatekeeper_avancado_loop.sh
```

### Paragem

```bash
# Método 1: Via npm
npm run gatekeeper-avancado:stop

# Método 2: Via VSCode
# Ctrl+Shift+P -> "Tasks: Run Task" -> "Ordem: Parar Gatekeeper Avançado"

# Método 3: Direto
rm -f ordem/gatekeeper_avancado/.gatekeeper_avancado.lock
```

## 🔧 Personalização para o projeto Ordem

### 1. Ajustar diagnósticos específicos

Editar `ordem/gatekeeper_avancado/gatekeeper_avancado_loop.sh` e modificar a função `run_diagnostics()`:

```bash
# Exemplo: Verificar se o backend da Ordem está ativo
if pgrep -f "ordem.*backend" >/dev/null 2>&1; then
    log_message "INFO" "✅ Backend Ordem: ATIVO"
else
    log_message "WARNING" "⚠️ Backend Ordem: INATIVO"
fi

# Exemplo: Verificar ficheiros de configuração da Ordem
local ordem_configs=("./ordem/config.json" "./ordem/.env")
for config_file in "${ordem_configs[@]}"; do
    if [[ -f "$config_file" ]]; then
        log_message "INFO" "✅ Config Ordem: $config_file existe"
    else
        log_message "WARNING" "⚠️ Config Ordem: $config_file AUSENTE"
    fi
done
```

### 2. Ajustar intervalos conforme necessário

```bash
# Para desenvolvimento (mais frequente)
INTERVAL=30        # 30 segundos
ERROR_INTERVAL=15  # 15 segundos

# Para produção (menos frequente)
INTERVAL=300       # 5 minutos
ERROR_INTERVAL=60  # 1 minuto
```

### 3. Integrar com sistema de notificações da Ordem

```bash
# Exemplo: Enviar alerta via webhook
send_ordem_alert() {
    local level="$1"
    local message="$2"

    if command -v curl >/dev/null 2>&1; then
        curl -X POST "https://ordem-api.com/alerts" \
            -H "Content-Type: application/json" \
            -d "{\"level\":\"$level\",\"message\":\"$message\",\"timestamp\":\"$(date -Iseconds)\"}"
    fi
}

# Usar nos diagnósticos
if [[ $disk_usage -gt 90 ]]; then
    log_message "WARNING" "⚠️ Espaço em disco: CRÍTICO (${disk_usage}% usado)"
    send_ordem_alert "WARNING" "Disco crítico: ${disk_usage}% usado"
fi
```

## 📊 Monitorização integrada

### Dashboard da Ordem

- Adicionar widget para mostrar status do gatekeeper avançado
- Integrar logs do gatekeeper avançado no dashboard principal
- Configurar alertas visuais para problemas críticos

### API da Ordem

```python
# Exemplo de endpoint para status do gatekeeper avançado
@app.get("/api/gatekeeper-avancado/status")
def get_gatekeeper_avancado_status():
    lock_file = "./ordem/gatekeeper_avancado/.gatekeeper_avancado.lock"
    is_running = os.path.exists(lock_file)

    # Ler último log
    log_file = f"./ordem/gatekeeper_avancado/gatekeeper_avancado_logs/gatekeeper_avancado_{datetime.now().strftime('%Y%m%d')}.log"
    last_log = ""
    if os.path.exists(log_file):
        with open(log_file, 'r') as f:
            lines = f.readlines()
            last_log = lines[-1].strip() if lines else ""

    return {
        "running": is_running,
        "last_check": last_log,
        "status": "healthy" if is_running else "stopped"
    }
```

## 🔄 Integração com CI/CD

### GitHub Actions

```yaml
# .github/workflows/gatekeeper-avancado.yml
name: Gatekeeper Avançado Health Check
on:
  schedule:
    - cron: "*/5 * * * *" # A cada 5 minutos

jobs:
  watchdog-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Check Gatekeeper Avançado Status
        run: |
          if [[ -f "./ordem/gatekeeper_avancado/.gatekeeper_avancado.lock" ]]; then
            echo "✅ Gatekeeper Avançado está ativo"
          else
            echo "❌ Gatekeeper Avançado não está ativo"
            exit 1
          fi
```

## 🛡️ Segurança e permissões

### Utilizador dedicado

```bash
# Criar utilizador para o gatekeeper avançado
sudo useradd -r -s /bin/bash ordem-gatekeeper

# Configurar permissões
sudo chown -R ordem-gatekeeper:ordem-gatekeeper ./ordem/gatekeeper_avancado/
sudo chmod 750 ./ordem/gatekeeper_avancado/gatekeeper_avancado_loop.sh
```

### Execução segura

```bash
# Executar como utilizador dedicado
sudo -u ordem-gatekeeper ./ordem/gatekeeper_avancado/gatekeeper_avancado_loop.sh
```

## 📈 Métricas e alertas

### Integração com Prometheus

```bash
# Exportar métricas do gatekeeper avançado
export_gatekeeper_avancado_metrics() {
    local metrics_file="./ordem/gatekeeper_avancado/metrics.prom"

    cat > "$metrics_file" << EOF
# HELP gatekeeper_avancado_checks_total Total number of gatekeeper avançado checks
# TYPE gatekeeper_avancado_checks_total counter
gatekeeper_avancado_checks_total{status="success"} $success_count
gatekeeper_avancado_checks_total{status="error"} $error_count

# HELP gatekeeper_avancado_last_check_timestamp Timestamp of last check
# TYPE gatekeeper_avancado_last_check_timestamp gauge
gatekeeper_avancado_last_check_timestamp $(date +%s)
EOF
}
```

## 🔍 Troubleshooting específico da Ordem

### Problemas comuns

1. **Gatekeeper Avançado não inicia**: Verificar permissões e dependências
2. **Falsos positivos**: Ajustar thresholds para ambiente da Ordem
3. **Logs não aparecem**: Verificar diretório e permissões de escrita
4. **Integração com API falha**: Verificar conectividade e autenticação

### Comandos de diagnóstico

```bash
# Verificar status
ps aux | grep gatekeeper_avancado

# Verificar logs em tempo real
tail -f ./ordem/gatekeeper_avancado/gatekeeper_avancado_logs/gatekeeper_avancado_$(date +%Y%m%d).log

# Testar conectividade
curl -f http://localhost:3000/api/health || echo "API Ordem inacessível"

# Verificar espaço em disco
df -h | grep -E "(Filesystem|/dev/)"
```

---

**Preparado para integração com o projeto Ordem**  
**Baseado no Dobbie Sentinel do Projeto Viriato**
