#!/bin/bash

# ==================================================
# FINAL SETUP - RESEND API KEY UPDATE
# ==================================================

RESEND_API_KEY="$1"

if [ -z "$RESEND_API_KEY" ]; then
  echo "❌ ERRO: Forneça a chave Resend como argumento"
  echo ""
  echo "Uso: ./setup-resend-key.sh re_your_api_key_here"
  exit 1
fi

if [[ ! "$RESEND_API_KEY" =~ ^re_ ]]; then
  echo "❌ ERRO: Chave inválida. Deve começar com 're_'"
  exit 1
fi

echo "Atualizando Lambda com RESEND_API_KEY..."
echo ""

# Update Lambda environment variable
aws lambda update-function-configuration \
  --function-name linear-hub-contact-api \
  --environment "Variables={RESEND_API_KEY=$RESEND_API_KEY}" \
  --region us-east-1

if [ $? -eq 0 ]; then
  echo ""
  echo "✅ SUCESSO! Lambda atualizada com RESEND_API_KEY"
  echo ""
  echo "Próximas etapas:"
  echo "1. Aguarde 30 segundos para a Lambda recarregar"
  echo "2. Teste o formulário em: https://linear-hub.com.br"
  echo "3. Você deve receber emails em: contato@linear-hub.com.br"
  echo ""
  echo "Status Final:"
  aws lambda get-function-configuration \
    --function-name linear-hub-contact-api \
    --query 'Environment.Variables.RESEND_API_KEY' \
    --output text | sed 's/^/   RESEND_API_KEY: /'
else
  echo "❌ ERRO ao atualizar Lambda"
  exit 1
fi
