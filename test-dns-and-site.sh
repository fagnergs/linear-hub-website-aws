#!/bin/bash

# 🧪 Script de Teste - Validar DNS e Site
# Uso: ./test-dns-and-site.sh

echo "╔════════════════════════════════════════════════════════════════════════╗"
echo "║                  🧪 TESTE: DNS + SITE ONLINE                         ║"
echo "╚════════════════════════════════════════════════════════════════════════╝"
echo ""

DOMAIN="linear-hub.com.br"
CLOUDFRONT="d1dmp1hz6w68o3.cloudfront.net"

# Teste 1: DNS Resolution
echo "1️⃣  Testando DNS Resolution..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if nslookup $DOMAIN > /dev/null 2>&1; then
    echo "✅ DNS resolve: $DOMAIN"
    nslookup $DOMAIN | grep -A1 "Name:"
else
    echo "❌ DNS não resolvendo ainda (propagação em andamento)"
fi
echo ""

# Teste 2: HTTPS Connection
echo "2️⃣  Testando HTTPS Connection..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if curl -s -I https://$DOMAIN > /dev/null 2>&1; then
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" https://$DOMAIN)
    if [ "$HTTP_CODE" = "200" ]; then
        echo "✅ Site respondendo com HTTP 200"
    else
        echo "⚠️  Site respondendo com HTTP $HTTP_CODE"
    fi
else
    echo "❌ Não conseguiu conectar (verifique DNS)"
fi
echo ""

# Teste 3: CloudFront Direct
echo "3️⃣  Testando CloudFront Direto..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" https://$CLOUDFRONT/)
if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ CloudFront online: $CLOUDFRONT"
else
    echo "❌ CloudFront não respondendo (HTTP $HTTP_CODE)"
fi
echo ""

# Teste 4: Certificate Check
echo "4️⃣  Testando SSL Certificate..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if echo | openssl s_client -servername $DOMAIN -connect $DOMAIN:443 2>/dev/null | grep -q "Verify return code: 0"; then
    echo "✅ SSL Certificate válido"
else
    echo "⚠️  Verifique SSL certificate (pode ser CloudFront default)"
fi
echo ""

# Teste 5: Content Check
echo "5️⃣  Verificando conteúdo..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

CONTENT=$(curl -s https://$CLOUDFRONT/ | grep -o "Linear Hub\|IA First" | head -1)
if [ -n "$CONTENT" ]; then
    echo "✅ Conteúdo do site detectado"
else
    echo "⚠️  Conteúdo não encontrado (pode estar em processo)"
fi
echo ""

# Resumo
echo "╔════════════════════════════════════════════════════════════════════════╗"
echo "║                        📋 RESUMO DO TESTE                             ║"
echo "╚════════════════════════════════════════════════════════════════════════╝"
echo ""
echo "Domain: $DOMAIN"
echo "CloudFront: $CLOUDFRONT"
echo ""
echo "PRÓXIMOS PASSOS:"
echo "1. Aguarde propagação DNS (5-30 minutos)"
echo "2. Execute este script novamente"
echo "3. Se todos os testes passarem, site está pronto"
echo ""
