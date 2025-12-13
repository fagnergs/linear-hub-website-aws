#!/bin/bash

echo "╔════════════════════════════════════════════════╗"
echo "║  TESTE RÁPIDO DO FORMULÁRIO DE CONTATO        ║"
echo "╚════════════════════════════════════════════════╝"
echo ""

# URL da API
API_URL="https://xsp6ymu9u6.execute-api.us-east-1.amazonaws.com/prod/contact"

echo "🔗 API Endpoint: $API_URL"
echo ""

# Teste 1: Verificar se endpoint responde
echo "1️⃣  Teste de conectividade..."
if curl -s -o /dev/null -w "%{http_code}" "$API_URL" -X OPTIONS; then
  echo " ✅ Endpoint acessível"
else
  echo " ❌ Endpoint não responde"
  exit 1
fi

echo ""
echo "2️⃣  Teste com formulário de contato..."
echo ""

# Dados de teste
TEST_DATA='{
  "name": "Test User",
  "email": "test@example.com",
  "company": "Test Company",
  "subject": "Teste de Formulário",
  "message": "Esta é uma mensagem de teste do formulário de contato."
}'

echo "📝 Enviando dados:"
echo "$TEST_DATA" | jq '.'
echo ""

# Fazer requisição
RESPONSE=$(curl -s -X POST "$API_URL" \
  -H "Content-Type: application/json" \
  -d "$TEST_DATA")

echo "📦 Resposta da API:"
echo "$RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"
echo ""

# Verificar se foi sucesso
if echo "$RESPONSE" | grep -q "sucesso"; then
  echo "✅ TESTE PASSOU! Formulário funcionando."
  exit 0
else
  echo "❌ TESTE FALHOU. Verifique a resposta acima."
  exit 1
fi
