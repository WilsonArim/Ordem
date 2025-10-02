# 🛡️ GATEKEEPER AVANÇADO - Sistema de Monitorização Contínua

**Extraído do Projeto Viriato - Dobbie Sentinel**

## 📋 O que é

O Gatekeeper Avançado é um sistema de monitorização contínua baseado no Dobbie Sentinel do Projeto Viriato. Executa verificações de segurança a cada 60 segundos, detectando problemas de conectividade, recursos do sistema, integridade de ficheiros e logs de erro.

## 🎯 Quando usar

- **Monitorização 24/7** de sistemas críticos
- **Detecção precoce** de problemas de infraestrutura
- **Auditoria contínua** de integridade do sistema
- **Backup** para sistemas de monitorização mais complexos

## 🚀 Como iniciar

```bash
# Tornar executável
chmod +x gatekeeper_avancado_loop.sh

# Executar
./gatekeeper_avancado_loop.sh
```

## 🛑 Como parar

### Método 1: Interrupção limpa

```bash
# Pressionar Ctrl+C no terminal onde está a correr
```

### Método 2: Remover lockfile

```bash
# Se o processo ficar "preso"
rm .gatekeeper_avancado.lock
```

### Método 3: Matar processo

```bash
# Encontrar PID
ps aux | grep gatekeeper_avancado_loop

# Matar processo
kill -TERM <PID>
```

## 📁 Estrutura de ficheiros

```
gatekeeper_avancado/
├── gatekeeper_avancado_loop.sh          # Script principal
├── GATEKEEPER_AVANCADO.md        # Este manual
├── .gatekeeper_avancado.lock           # Lockfile (criado automaticamente)
└── gatekeeper_avancado_logs/           # Diretório de logs
    └── gatekeeper_avancado_YYYYMMDD.log # Log diário
```

## 📊 Logs e monitorização

### Localização dos logs

- **Log principal**: `gatekeeper_avancado_logs/gatekeeper_avancado_YYYYMMDD.log`
- **Formato**: `[LEVEL] [TIMESTAMP] MESSAGE`

### Níveis de log

- `INFO`: Operações normais
- `WARNING`: Problemas não críticos
- `ERROR`: Erros que requerem atenção

### Exemplo de log

```
[INFO] [2025-01-02 14:30:15] 🛡️ GATEKEEPER AVANÇADO INICIADO
[INFO] [2025-01-02 14:30:15] ▶️ Diagnóstico iniciado
[INFO] [2025-01-02 14:30:15] ✅ Conectividade de rede: OK
[INFO] [2025-01-02 14:30:15] ✅ Espaço em disco: OK (45% usado)
[WARNING] [2025-01-02 14:30:15] ⚠️ Memória: ALTA (85% usado)
[INFO] [2025-01-02 14:30:15] ✅ Diagnóstico concluído
```

## 🔍 Diagnósticos executados

### 1. Conectividade de rede

- **Teste**: Ping para 8.8.8.8
- **Falha**: Problemas de conectividade

### 2. Espaço em disco

- **Teste**: Verificação do disco raiz (/)
- **Alerta**: > 90% de uso

### 3. Memória

- **Teste**: Verificação de RAM disponível
- **Alerta**: > 90% de uso

### 4. Processos críticos

- **Teste**: Verificação se servidor Python está ativo
- **Ajustar**: Modificar `pgrep -f "python.*main:app"` conforme necessário

### 5. Logs de sistema

- **Teste**: Verificação de logs de erro nos últimos 24h
- **Alerta**: Presença de erros críticos

### 6. Integridade de ficheiros

- **Teste**: Verificação de ficheiros críticos do sistema
- **Alerta**: Ficheiros ausentes

## ⚙️ Configurações

### Intervalos (editáveis no script)

```bash
INTERVAL=60        # Intervalo normal (60 segundos)
ERROR_INTERVAL=30  # Intervalo em caso de erro (30 segundos)
```

### Ficheiros críticos (personalizáveis)

```bash
config_files=("/etc/passwd" "/etc/group")
```

### Processos críticos (personalizáveis)

```bash
pgrep -f "python.*main:app"  # Ajustar conforme necessário
```

## 🔧 Dependências

### Binários necessários

- `ping` - Teste de conectividade
- `df` - Informação de disco
- `free` - Informação de memória
- `pgrep` - Verificação de processos
- `find` - Busca de ficheiros
- `grep` - Filtragem de texto

### Instalação (Ubuntu/Debian)

```bash
# Já incluído na maioria dos sistemas
sudo apt update
sudo apt install procps-ng util-linux
```

### Instalação (CentOS/RHEL)

```bash
# Já incluído na maioria dos sistemas
sudo yum install procps-ng util-linux
```

## 🚨 Códigos de saída

- `0`: Sucesso
- `1`: Erro crítico ou gatekeeper avançado já em execução
- `2`: Dependências em falta

## 🔄 Integração com sistema

### Como serviço systemd

```bash
# Criar ficheiro de serviço
sudo tee /etc/systemd/system/gatekeeper-avancado.service > /dev/null <<EOF
[Unit]
Description=Gatekeeper Avançado Monitor
After=network.target

[Service]
Type=simple
User=gatekeeper
WorkingDirectory=/path/to/gatekeeper_avancado
ExecStart=/path/to/gatekeeper_avancado/gatekeeper_avancado_loop.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Ativar serviço
sudo systemctl daemon-reload
sudo systemctl enable gatekeeper-avancado
sudo systemctl start gatekeeper-avancado
```

### Como cron job

```bash
# Adicionar ao crontab
@reboot /path/to/gatekeeper_avancado/gatekeeper_avancado_loop.sh &
```

## 🛠️ Personalização

### Adicionar novos diagnósticos

1. Adicionar função de diagnóstico no script
2. Chamar a função em `run_diagnostics()`
3. Implementar lógica de detecção e logging

### Exemplo de diagnóstico personalizado

```bash
check_custom_service() {
    if systemctl is-active --quiet custom-service; then
        log_message "INFO" "✅ Serviço personalizado: ATIVO"
    else
        log_message "WARNING" "⚠️ Serviço personalizado: INATIVO"
    fi
}
```

## 🔍 Troubleshooting

### Gatekeeper Avançado não inicia

```bash
# Verificar permissões
ls -la gatekeeper_avancado_loop.sh

# Verificar dependências
./gatekeeper_avancado_loop.sh  # Mostrar erros de dependências

# Verificar lockfile
ls -la .gatekeeper_avancado.lock
```

### Logs não aparecem

```bash
# Verificar diretório de logs
ls -la gatekeeper_avancado_logs/

# Verificar permissões de escrita
touch gatekeeper_avancado_logs/test.log
```

### Muitos falsos positivos

- Ajustar thresholds nos diagnósticos
- Modificar intervalos de verificação
- Personalizar critérios de alerta

## 📈 Monitorização avançada

### Integração com ferramentas externas

- **Prometheus**: Exportar métricas
- **Grafana**: Dashboards visuais
- **AlertManager**: Notificações automáticas
- **Slack/Discord**: Alertas em tempo real

### Log rotation

```bash
# Adicionar ao crontab
0 0 * * * find /path/to/gatekeeper_avancado_logs -name "*.log" -mtime +7 -delete
```

## 🔒 Segurança

### Permissões recomendadas

```bash
chmod 750 gatekeeper_avancado_loop.sh
chmod 755 gatekeeper_avancado_logs/
chown gatekeeper:gatekeeper gatekeeper_avancado_loop.sh
```

### Execução como utilizador dedicado

```bash
# Criar utilizador
sudo useradd -r -s /bin/bash gatekeeper

# Executar como utilizador
sudo -u gatekeeper ./gatekeeper_avancado_loop.sh
```

## 📞 Suporte

Para questões sobre este gatekeeper avançado:

1. Verificar logs em `gatekeeper_avancado_logs/`
2. Consultar este README
3. Revisar implementação original no Viriato
4. Ajustar configurações conforme necessário

---

**Baseado no Dobbie Sentinel do Projeto Viriato**  
**Extraído em: 2025-01-02**
