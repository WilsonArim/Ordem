#!/bin/bash
"""
🛡️ GATEKEEPER AVANÇADO - SISTEMA DE MONITORIZAÇÃO CONTÍNUA

Baseado no Dobbie Sentinel do Projeto Viriato.
Executa verificações de segurança a cada 60 segundos.

USO:
    chmod +x gatekeeper_avancado_loop.sh
    ./gatekeeper_avancado_loop.sh

PARAGEM:
    Ctrl+C ou remover .gatekeeper_avancado.lock
"""

set -euo pipefail

# Configurações
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCK_FILE="${SCRIPT_DIR}/.gatekeeper_avancado.lock"
LOG_DIR="${SCRIPT_DIR}/gatekeeper_avancado_logs"
LOG_FILE="${LOG_DIR}/gatekeeper_avancado_$(date +%Y%m%d).log"
INTERVAL=60  # Mesmo intervalo do Viriato (60 segundos)
ERROR_INTERVAL=30  # Intervalo em caso de erro (30 segundos)

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função de logging
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Criar diretório de logs se não existir
    mkdir -p "$LOG_DIR"
    
    # Escrever no log
    echo "[$level] [$timestamp] $message" >> "$LOG_FILE"
    
    # Output colorido para console
    case "$level" in
        "INFO")
            echo -e "${GREEN}[INFO]${NC} [$timestamp] $message"
            ;;
        "WARNING")
            echo -e "${YELLOW}[WARNING]${NC} [$timestamp] $message"
            ;;
        "ERROR")
            echo -e "${RED}[ERROR]${NC} [$timestamp] $message"
            ;;
        *)
            echo -e "${BLUE}[$level]${NC} [$timestamp] $message"
            ;;
    esac
}

# Função de limpeza
cleanup() {
    log_message "INFO" "🛑 Gatekeeper Avançado interrompido pelo utilizador"
    rm -f "$LOCK_FILE"
    log_message "INFO" "✅ Sistema encerrado com segurança"
    exit 0
}

# Configurar trap para Ctrl+C
trap cleanup INT TERM

# Verificar se já está em execução
if [[ -f "$LOCK_FILE" ]]; then
    log_message "ERROR" "❌ Gatekeeper Avançado já está em execução (lockfile existe: $LOCK_FILE)"
    log_message "ERROR" "💡 Para forçar paragem: rm $LOCK_FILE"
    exit 1
fi

# Criar lockfile
echo $$ > "$LOCK_FILE"

# Função principal de diagnóstico
run_diagnostics() {
    local cycle_start=$(date '+%Y-%m-%d %H:%M:%S')
    log_message "INFO" "▶️ Diagnóstico iniciado"
    
    # 🔍 Diagnóstico 1: Verificar conectividade de rede
    if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        log_message "INFO" "✅ Conectividade de rede: OK"
    else
        log_message "WARNING" "⚠️ Conectividade de rede: FALHA"
    fi
    
    # 🔍 Diagnóstico 2: Verificar espaço em disco
    local disk_usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    if [[ $disk_usage -lt 90 ]]; then
        log_message "INFO" "✅ Espaço em disco: OK (${disk_usage}% usado)"
    else
        log_message "WARNING" "⚠️ Espaço em disco: CRÍTICO (${disk_usage}% usado)"
    fi
    
    # 🔍 Diagnóstico 3: Verificar memória
    local mem_usage=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')
    if [[ $mem_usage -lt 90 ]]; then
        log_message "INFO" "✅ Memória: OK (${mem_usage}% usado)"
    else
        log_message "WARNING" "⚠️ Memória: ALTA (${mem_usage}% usado)"
    fi
    
    # 🔍 Diagnóstico 4: Verificar processos críticos (ajustar conforme necessário)
    # Exemplo: verificar se o servidor web está ativo
    if pgrep -f "python.*main:app" >/dev/null 2>&1; then
        log_message "INFO" "✅ Servidor Python: ATIVO"
    else
        log_message "WARNING" "⚠️ Servidor Python: INATIVO"
    fi
    
    # 🔍 Diagnóstico 5: Verificar logs de erro recentes
    local error_count=$(find /var/log -name "*.log" -type f -mtime -1 -exec grep -l "ERROR\|FATAL\|CRITICAL" {} \; 2>/dev/null | wc -l)
    if [[ $error_count -eq 0 ]]; then
        log_message "INFO" "✅ Logs de sistema: SEM ERROS RECENTES"
    else
        log_message "WARNING" "⚠️ Logs de sistema: $error_count ficheiros com erros"
    fi
    
    # 🔍 Diagnóstico 6: Verificar integridade de ficheiros críticos
    # Exemplo: verificar se ficheiros de configuração existem
    local config_files=("/etc/passwd" "/etc/group")
    for config_file in "${config_files[@]}"; do
        if [[ -f "$config_file" ]]; then
            log_message "INFO" "✅ Ficheiro crítico: $config_file existe"
        else
            log_message "ERROR" "❌ Ficheiro crítico: $config_file AUSENTE"
            return 1
        fi
    done
    
    local cycle_end=$(date '+%Y-%m-%d %H:%M:%S')
    log_message "INFO" "✅ Diagnóstico concluído ($cycle_start -> $cycle_end)"
    return 0
}

# Função principal
main() {
    log_message "INFO" "🛡️ WATCHDOG INICIADO"
    log_message "INFO" "🔍 Monitorização contínua ativada"
    log_message "INFO" "⏰ Intervalo normal: ${INTERVAL}s"
    log_message "INFO" "⏰ Intervalo erro: ${ERROR_INTERVAL}s"
    log_message "INFO" "📝 Logs em: $LOG_FILE"
    
    local consecutive_errors=0
    local max_consecutive_errors=5
    
    while true; do
        if run_diagnostics; then
            consecutive_errors=0
            log_message "INFO" "💤 Aguardando ${INTERVAL}s até próximo ciclo..."
            sleep "$INTERVAL"
        else
            consecutive_errors=$((consecutive_errors + 1))
            log_message "ERROR" "❌ Erro no diagnóstico (tentativa $consecutive_errors/$max_consecutive_errors)"
            
            if [[ $consecutive_errors -ge $max_consecutive_errors ]]; then
                log_message "ERROR" "💥 Muitos erros consecutivos ($consecutive_errors). Encerrando."
                rm -f "$LOCK_FILE"
                exit 1
            fi
            
            log_message "INFO" "💤 Aguardando ${ERROR_INTERVAL}s antes de tentar novamente..."
            sleep "$ERROR_INTERVAL"
        fi
    done
}

# Verificar dependências
check_dependencies() {
    local deps=("ping" "df" "free" "pgrep" "find" "grep")
    local missing_deps=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing_deps+=("$dep")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_message "ERROR" "❌ Dependências em falta: ${missing_deps[*]}"
        log_message "ERROR" "💡 Instale as dependências antes de executar o watchdog"
        exit 1
    fi
}

# Executar
check_dependencies
main
