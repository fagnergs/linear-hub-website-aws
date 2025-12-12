# 🚀 Quick Reference Card

## Valores AWS para Colar

### GitHub Secrets

```
AWS_ACCESS_KEY_ID: <stored-in-github-secrets>
AWS_SECRET_ACCESS_KEY: <stored-in-github-secrets>
AWS_REGION: us-east-1
S3_BUCKET: linear-hub-website-prod-1765543563
CLOUDFRONT_DISTRIBUTION_ID: EDQZRUQFXIMQ6
LAMBDA_FUNCTION_NAME: linear-hub-contact-api
RESEND_API_KEY: <your-resend-key-here>
```

### DNS Record

```
Type: A ou CNAME
Name: linear-hub.com.br
Value: d1dmp1hz6w68o3.cloudfront.net
TTL: 300 (5 min)

Opcional (www):
Type: CNAME
Name: www.linear-hub.com.br
Value: d1dmp1hz6w68o3.cloudfront.net
TTL: 300
```

## Comandos Rápidos

### 1. Adicionar GitHub Secrets (com gh CLI)

```bash
# Instalar GitHub CLI se não tiver
brew install gh

# Autenticar
gh auth login

# Executar script
chmod +x aws/setup-github-secrets.sh
./aws/setup-github-secrets.sh
```

### 2. Fazer Deploy

```bash
git push origin main
```

### 3. Monitorar Deployment

```bash
# Ver último workflow
gh run list --repo fagnergs/linear-hub-website-aws -n 1

# Ver status detalhado
gh run view <run-id>

# Ver logs
gh run view <run-id> --log
```

### 4. Verificar DNS

```bash
# macOS/Linux
nslookup linear-hub.com.br
# ou
dig linear-hub.com.br
# ou
host linear-hub.com.br

# Verificar propagação global
# https://www.whatsmydns.net/?domain=linear-hub.com.br
```

### 5. Testar Site

```bash
# Simples (verificar se está online)
curl -I https://linear-hub.com.br/

# Testar formulário
curl -X POST https://linear-hub.com.br/api/contact \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "subject": "Test Subject",
    "message": "Test message"
  }'
```

## Links Importantes

- GitHub Repo: https://github.com/fagnergs/linear-hub-website-aws
- GitHub Actions: https://github.com/fagnergs/linear-hub-website-aws/actions
- GitHub Secrets: https://github.com/fagnergs/linear-hub-website-aws/settings/secrets/actions
- AWS CloudFront: https://console.aws.amazon.com/cloudfront/
- AWS Lambda: https://console.aws.amazon.com/lambda/
- Resend Dashboard: https://resend.com/emails

## Documentação Completa

- **FINAL_STEPS.md** ← Leia isto primeiro!
- **AWS_DEPLOYMENT_SUMMARY.md** - Todos os valores criados
- **AWS_CREDENTIALS.md** - IAM user e S3 info
- **AWS_SETUP.md** - Arquitetura detalhada

## Timeline

- T+0: Começar
- T+2min: GitHub Secrets configurados ✓
- T+5min: DNS atualizado (esperar 5-30min de propagação)
- T+1min: git push origin main
- T+5min: GitHub Actions compilando
- T+30min: DNS propagado
- T+35min: Site LIVE em https://linear-hub.com.br

## Troubleshooting Rápido

| Problema | Solução |
|----------|---------|
| GitHub Actions falhou | Verificar se todos 7 secrets foram adicionados |
| Site retorna 403 | Esperar CloudFront propagar (5-10 min) |
| DNS não resolve | Verificar registrador, aguardar 5-30 min |
| Email não chega | Validar RESEND_API_KEY, verificar logs Lambda |
| Cold start lento | Normal (2-3s primeira vez, depois <100ms) |

---

**Você está 75% pronto. Apenas 5 passos faltam!** 🎉
