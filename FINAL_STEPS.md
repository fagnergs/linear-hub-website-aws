# 🚀 Últimos 5 Passos para Deploy

## Status: 75% Concluído ✅

Infraestrutura AWS completa. Faltam apenas 5 passos finais!

---

## 📋 Passo 1️⃣: Adicionar GitHub Secrets (2 min)

### Opção A: Via Script Automático (Recomendado)

```bash
chmod +x aws/setup-github-secrets.sh
./aws/setup-github-secrets.sh
```

Você precisará ter:
- **GitHub CLI instalado**: https://cli.github.com/
- **Autenticado com**: `gh auth login`

### Opção B: Manual via GitHub Web

1. Vá para: **https://github.com/fagnergs/linear-hub-website-aws/settings/secrets/actions**

2. Clique em **"New repository secret"** e adicione cada um:

| Secret Name | Valor |
|------------|-------|
| `AWS_ACCESS_KEY_ID` | `<stored-in-github-secrets>` |
| `AWS_SECRET_ACCESS_KEY` | `<stored-in-github-secrets>` |
| `AWS_REGION` | `us-east-1` |
| `S3_BUCKET` | `linear-hub-website-prod-1765543563` |
| `CLOUDFRONT_DISTRIBUTION_ID` | `EDQZRUQFXIMQ6` |
| `LAMBDA_FUNCTION_NAME` | `linear-hub-contact-api` |
| `RESEND_API_KEY` | `re_xxxxx` (de Resend.com) |

⚠️ **IMPORTANTE**: Proteja suas credenciais AWS! Não commit ao git.

---

## 🌐 Passo 2️⃣: Atualizar DNS (5 min - Manual)

### Onde sua estando hospedado linear-hub.com.br?

Você precisa acessar o DNS registrador (geralmente onde comprou o domínio).

### Registros a Adicionar/Atualizar:

```
Tipo: A ou CNAME
Nome: linear-hub.com.br
Valor: d1dmp1hz6w68o3.cloudfront.net
TTL: 300 (5 minutos)

---

Tipo: CNAME (opcional para www)
Nome: www.linear-hub.com.br
Valor: d1dmp1hz6w68o3.cloudfront.net
TTL: 300
```

### Exemplos de Registradores:

- **Namecheap**: https://www.namecheap.com/ (painel DNS)
- **GoDaddy**: https://www.godaddy.com/ (gerenciar DNS)
- **AWS Route 53**: https://console.aws.amazon.com/route53/
- **Cloudflare**: https://www.cloudflare.com/ (free DNS)

### Verificar se DNS foi propagado:

```bash
# Via terminal
nslookup linear-hub.com.br
# ou
dig linear-hub.com.br

# Via site
https://www.whatsmydns.net/
```

⏱️ **Propação**: Pode levar 5-30 minutos

---

## ⚙️ Passo 3️⃣: Configurar API Endpoint (1 min)

### Opção A: Usar endpoint padrão (Recomendado)

O `next.config.js` já está configurado com:

```javascript
publicRuntimeConfig: {
  apiEndpoint: process.env.NEXT_PUBLIC_API_ENDPOINT || '/api/contact',
}
```

Isso significa:
- **Development**: `/api/contact` (local Next.js API)
- **Production**: Usa `NEXT_PUBLIC_API_ENDPOINT` se definido

### Opção B: Definir API remota (Avançado)

Se quiser usar a API Gateway Lambda diretamente:

```bash
# Em .env.production.local (NÃO commitar!)
NEXT_PUBLIC_API_ENDPOINT=https://xsp6ymu9u6.execute-api.us-east-1.amazonaws.com/prod/contact
```

⚠️ **Nota**: O GitHub Actions CI/CD já está configurado para usar o endpoint local `/api/contact`

---

## 🚀 Passo 4️⃣: Deploy (1 min)

Tudo que você precisa fazer é fazer push para `main`:

```bash
git push origin main
```

**O que vai acontecer automaticamente:**

1. GitHub Actions workflow é acionado
2. Compila Next.js (`npm run build`)
3. Faz upload para S3
4. Invalida cache CloudFront
5. Deploy Lambda (optional)
6. Status é mostrado na aba **Actions**

### Monitorar deployment:

```bash
# Via terminal
gh run list --repo fagnergs/linear-hub-website-aws

# Via web
https://github.com/fagnergs/linear-hub-website-aws/actions
```

---

## ✅ Passo 5️⃣: Testar (2 min)

### Aguardar DNS (5-30 min)

```bash
# Verificar propagação
nslookup linear-hub.com.br
# Deveria retornar: d1dmp1hz6w68o3.cloudfront.net
```

### Testar Site:

```bash
# Via curl
curl -I https://linear-hub.com.br/

# Deveria retornar:
# HTTP/2 200
# CloudFront-Distribution-Id: EDQZRUQFXIMQ6
```

### Testar Formulário de Contato:

```bash
# Via curl (teste básico)
curl -X POST https://linear-hub.com.br/api/contact \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Teste",
    "email": "teste@example.com",
    "subject": "Teste",
    "message": "Teste de contato"
  }'

# Deveria retornar:
# {"message":"Mensagem enviada com sucesso!"}
```

### Testar no Browser:

1. Acesse: **https://linear-hub.com.br**
2. Preencha o formulário de contato
3. Envie
4. Verifique:
   - Resposta no navegador
   - Email recebido em `contato@linear-hub.com.br` (se Resend configurado)

---

## 🎯 Checklist Final

- [ ] GitHub Secrets adicionados (7 secrets)
- [ ] DNS records atualizados
- [ ] DNS propagado (nslookup retorna CloudFront)
- [ ] Deployment executou com sucesso (GitHub Actions)
- [ ] Site carrega em HTTPS
- [ ] Formulário funciona
- [ ] Email recebido (se Resend configurado)

---

## 📊 Status Resumido

| Componente | Status | Próximo Passo |
|-----------|--------|--------------|
| IAM User | ✅ Criado | - |
| S3 Bucket | ✅ Criado | - |
| CloudFront | ✅ Criado | DNS |
| Lambda | ✅ Criada | Secrets |
| API Gateway | ✅ Criada | Secrets |
| GitHub Actions | ✅ Configurado | Push main |
| GitHub Secrets | ⏳ Manual | Adicionar 7 secrets |
| DNS | ⏳ Manual | Atualizar registrador |
| Deploy | ⏳ Aguardando | git push origin main |
| Teste | ⏳ Aguardando | Testar site |

---

## ⏱️ Cronograma Estimado

```
Agora          Passo 1-2       Passo 3-4       Passo 5
│              (7 min)         (1 min)         (5 min)
├──────────────┼────────────────┼────────────────┼────────────────► 20 min
Começar        Secrets + DNS   Config + Push   Teste & Live
```

---

## 🔗 Links Úteis

- **AWS Deployment Summary**: `AWS_DEPLOYMENT_SUMMARY.md`
- **AWS Credentials**: `AWS_CREDENTIALS.md`
- **GitHub Actions**: https://github.com/fagnergs/linear-hub-website-aws/actions
- **GitHub Secrets Settings**: https://github.com/fagnergs/linear-hub-website-aws/settings/secrets/actions
- **AWS CloudFront**: https://console.aws.amazon.com/cloudfront/
- **AWS Lambda**: https://console.aws.amazon.com/lambda/
- **Resend Email**: https://resend.com/emails

---

## 🆘 Troubleshooting

### DNS não propagou
```bash
# Limpar DNS cache
sudo dscacheutil -flushcache  # macOS
ipconfig /flushdns            # Windows
systemctl restart systemd-resolved  # Linux
```

### GitHub Actions falhou
- Verificar logs em: Actions tab
- Validar que todos 7 secrets foram adicionados
- Verificar se S3_BUCKET e CLOUDFRONT_DISTRIBUTION_ID estão corretos

### Formulário não envia email
- Verificar se RESEND_API_KEY está correto
- Verificar se email de destino está validado no Resend
- Verificar logs em CloudWatch (AWS Console > Lambda > Logs)

### Site retorna 403/404
- Esperar CloudFront propagar (5-10 min)
- Verificar se S3 bucket policy está correta
- Verificar CloudFront distribution origin

---

**Pronto para começar? Execute o Passo 1 acima!** 🚀
