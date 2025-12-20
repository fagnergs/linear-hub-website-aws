#!/bin/bash

# Script de Setup - Alerta de Custo Diário
# Este script configura EventBridge para enviar alertas de custo diários via SNS

set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  🚀 Configurando Alertas de Custo Diários - Linear Hub        ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

AWS_REGION="us-east-1"
ACCOUNT_ID="781705467769"
RULE_NAME="linear-hub-daily-cost-alert-rule"
SNS_TOPIC_ARN="arn:aws:sns:${AWS_REGION}:${ACCOUNT_ID}:linear-hub-website-alerts"
SCHEDULE="cron(0 9 * * ? *)"  # 9:00 AM UTC todos os dias

echo "[1/3] Verificando Credenciais AWS..."
IDENTITY=$(aws sts get-caller-identity --region $AWS_REGION 2>/dev/null)
if [ $? -eq 0 ]; then
    echo "✅ Credenciais AWS: OK"
    ACCOUNT=$(echo $IDENTITY | grep -o '"Account": "[^"]*' | cut -d'"' -f4)
    echo "    Conta: $ACCOUNT"
else
    echo "❌ Credenciais AWS: FALHOU"
    echo "   Execute: aws configure"
    exit 1
fi

echo ""
echo "[2/3] Criando Regra EventBridge..."
RULE_OUTPUT=$(aws events put-rule \
    --name "$RULE_NAME" \
    --schedule-expression "$SCHEDULE" \
    --state ENABLED \
    --description "Alerta diário de custos para Linear Hub Website" \
    --region "$AWS_REGION" 2>&1)

if echo "$RULE_OUTPUT" | grep -q "RuleArn"; then
    RULE_ARN=$(echo "$RULE_OUTPUT" | grep -o 'arn:aws:events:[^"]*')
    echo "✅ Regra EventBridge Criada"
    echo "   Regra: $RULE_NAME"
    echo "   Agendamento: Diariamente às 9:00 AM UTC"
    echo "   ARN: $RULE_ARN"
else
    echo "⚠️  Regra pode existir ou erro ocorreu"
    echo "$RULE_OUTPUT" | head -5
fi

echo ""
echo "[3/3] Configurando Target SNS..."

# Remover targets antigos se existirem
echo "    Removendo targets antigos..."
aws events remove-targets \
    --rule "$RULE_NAME" \
    --ids "1" \
    --region "$AWS_REGION" 2>/dev/null || echo "    (Nenhum target antigo)"

# Adicionar target SNS
TARGET_OUTPUT=$(aws events put-targets \
    --rule "$RULE_NAME" \
    --targets "Id=1,Arn=$SNS_TOPIC_ARN,Input={\"alert\": \"relatorio-custo-diario\"}" \
    --region "$AWS_REGION" 2>&1)

if echo "$TARGET_OUTPUT" | grep -q "FailedEntryCount"; then
    FAILED=$(echo "$TARGET_OUTPUT" | grep -o '"FailedEntryCount": [0-9]*' | grep -o '[0-9]*')
    if [ "$FAILED" = "0" ]; then
        echo "✅ Target SNS Configurado"
        echo "   Target: $SNS_TOPIC_ARN"
    else
        echo "❌ Falha ao adicionar target: $TARGET_OUTPUT"
        exit 1
    fi
fi

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  ✅ CONFIGURAÇÃO COMPLETA!                                     ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "📊 Seus alertas diários foram configurados:"
echo ""
echo "   ✅ Regra EventBridge: $RULE_NAME"
echo "   ✅ Agendamento: Todos os dias às 9:00 AM UTC"
echo "   ✅ Destinatário: fagner.silva@linear-hub.com.br"
echo "   ✅ Tópico SNS: $SNS_TOPIC_ARN"
echo ""
echo "📧 Você receberá emails com informações de custo todos os dias"
echo ""
echo "🔍 Verifique sua configuração:"
echo "   aws events describe-rule --name $RULE_NAME --region $AWS_REGION"
echo ""
echo "🧪 Teste manualmente:"
echo "   aws sns publish --topic-arn $SNS_TOPIC_ARN \\"
echo "     --subject 'Teste de Alerta' --message 'Se você vê isto, funciona!' \\"
echo "     --region $AWS_REGION"
echo ""
echo "📝 Veja SETUP_ALERTAS_DIARIOS.md para mais informações"
echo ""
