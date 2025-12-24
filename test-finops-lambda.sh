#!/bin/bash

# Script simples de teste da Lambda FinOps

echo "🧪 Testando Lambda FinOps..."

cat > /tmp/test-payload.json << 'EOF'
{
  "mode": "current",
  "send_email": true
}
EOF

# Usar base64 para evitar problemas de encoding
PAYLOAD=$(cat /tmp/test-payload.json)
PAYLOAD_B64=$(echo -n "$PAYLOAD" | base64)

aws lambda invoke \
    --function-name linear-hub-finops-cost-extractor \
    --payload "$PAYLOAD_B64" \
    --region us-east-1 \
    /tmp/lambda-response.json

echo ""
echo "📄 Response:"
cat /tmp/lambda-response.json
echo ""

# Acompanhar logs
echo "📋 Últimas linhas de logs (aguarde 5 segundos)..."
sleep 5
aws logs tail /aws/lambda/linear-hub-finops-cost-extractor --follow --max-items 20 --region us-east-1 2>/dev/null || echo "Logs ainda não disponíveis"
