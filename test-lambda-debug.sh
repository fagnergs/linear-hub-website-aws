#!/bin/bash

echo "🔍 Testando Lambda com dados simples..."
echo ""

# Testar com dados mínimos
TEST_PAYLOAD='{
  "name": "João",
  "email": "joao@example.com",
  "subject": "Teste",
  "message": "Mensagem de teste"
}'

echo "📤 Enviando para Lambda:"
echo "$TEST_PAYLOAD"
echo ""

RESPONSE=$(curl -s -X POST "https://xsp6ymu9u6.execute-api.us-east-1.amazonaws.com/prod/contact" \
  -H "Content-Type: application/json" \
  -d "$TEST_PAYLOAD")

echo "📬 Resposta:"
echo "$RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$RESPONSE"

# Verificar logs
echo ""
echo "📋 Últimos logs da Lambda:"
aws logs tail /aws/lambda/linear-hub-contact-api --max-items 30 2>/dev/null | tail -20 || echo "Logs não disponíveis"
