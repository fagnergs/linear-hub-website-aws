#!/bin/bash
# Setup automático do agendador de extração de custos
# Configura o cron para executar o script de extração diariamente

set -e

SCRIPT_PATH="/Users/fagnergs/Documents/GitHub/linear-hub-website-aws/extract-costs.py"
LOG_DIR="/Users/fagnergs/Documents/GitHub/linear-hub-website-aws/logs"
LOG_FILE="$LOG_DIR/cost-extraction.log"

echo "📋 Configurando agendador de extração de custos..."
echo ""

# Criar diretório de logs se não existir
if [ ! -d "$LOG_DIR" ]; then
    mkdir -p "$LOG_DIR"
    echo "✅ Diretório de logs criado: $LOG_DIR"
fi

# Verificar se o script existe
if [ ! -f "$SCRIPT_PATH" ]; then
    echo "❌ Erro: Script não encontrado em $SCRIPT_PATH"
    exit 1
fi

# Tornar o script executável
chmod +x "$SCRIPT_PATH"
echo "✅ Script de extração permissões atualizadas"
echo ""

# Adicionar ao crontab (se ainda não existir)
CRON_JOB="0 9 * * * cd /Users/fagnergs/Documents/GitHub/linear-hub-website-aws && python3 extract-costs.py --current --send >> $LOG_FILE 2>&1"

# Verificar se já existe no crontab
if (crontab -l 2>/dev/null | grep -q "extract-costs.py"); then
    echo "⚠️  Tarefa de agendamento já existe no crontab"
else
    # Adicionar ao crontab
    (crontab -l 2>/dev/null || echo "") | {
        cat
        echo "$CRON_JOB"
    } | crontab -

    echo "✅ Tarefa de agendamento adicionada ao crontab"
fi

echo ""
echo "📅 Agendamento Configurado:"
echo "   └─ Horário: 09:00 UTC (diariamente)"
echo "   └─ Ação: Extrair custos do mês atual e enviar email"
echo "   └─ Log: $LOG_FILE"
echo ""

echo "📧 Email será enviado para:"
echo "   └─ fagner.silva@linear-hub.com.br"
echo ""

echo "📊 Modo de execução:"
echo "   └─ --current: Mostra custos parciais do mês (até hoje)"
echo "   └─ --send: Envia relatório automático via SNS"
echo ""

echo "🔍 Para visualizar o log:"
echo "   tail -f $LOG_FILE"
echo ""

echo "✅ Setup concluído com sucesso!"
