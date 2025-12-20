#!/bin/bash
# GUIA RÁPIDO DE ATIVAÇÃO - Copie e Cole os Comandos

# ============================================================================
# LINEAR HUB FINOPS - ATIVAR ALERTAS DIÁRIOS
# ============================================================================
# 
# Execute estes comandos no seu terminal para ativar alertas de custo diários
# Tempo estimado: 30 segundos
# 
# ============================================================================

# PASSO 1: Criar Regra EventBridge
# Esta regra será disparada todos os dias às 9:00 AM UTC
echo "Criando Regra EventBridge..."
aws events put-rule \
  --name linear-hub-daily-cost-alert-rule \
  --schedule-expression "cron(0 9 * * ? *)" \
  --state ENABLED \
  --description "Alerta de custo diário para Linear Hub Website" \
  --region us-east-1

echo "✅ Regra criada"
echo ""

# PASSO 2: Adicionar SNS como Target
# Isto informa à regra para enviar notificações ao seu Tópico SNS
echo "Adicionando Tópico SNS como target..."
aws events put-targets \
  --rule linear-hub-daily-cost-alert-rule \
  --targets 'Id=1,Arn=arn:aws:sns:us-east-1:781705467769:linear-hub-website-alerts,Input={"alert":"relatorio-custo-diario"}' \
  --region us-east-1

echo "✅ Target adicionado"
echo ""

# PASSO 3: Verificar Configuração
echo "Verificando setup..."
aws events describe-rule \
  --name linear-hub-daily-cost-alert-rule \
  --region us-east-1 | grep -E "State|ScheduleExpression"

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  ✅ ATIVAÇÃO COMPLETA!                                         ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "Seus alertas diários estão ATIVOS!"
echo ""
echo "📧 Você receberá emails todos os dias às 9:00 AM UTC"
echo "📊 Próximo alerta: Amanhã às 9:00 AM UTC"
echo ""
echo "🧪 OPCIONAL: Enviar um email de teste:"
echo ""
echo "   aws sns publish \\"
echo "     --topic-arn arn:aws:sns:us-east-1:781705467769:linear-hub-website-alerts \\"
echo "     --subject 'Alerta de Teste' \\"
echo "     --message 'Se você vê isto, seu sistema funciona!' \\"
echo "     --region us-east-1"
echo ""
