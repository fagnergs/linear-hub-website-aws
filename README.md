# Linear Hub Website

Website institucional moderno, responsivo e multilíngue para a Linear Hub.

**Status:** ✅ Em produção na AWS | **Visit:** https://linear-hub.com.br/

---

## 🚀 Stack

- **Next.js 14** - React framework (static export)
- **TypeScript** - Type safety
- **Tailwind CSS** - Styling
- **Framer Motion** - Animations
- **i18n** - Multilingual support (PT, EN, ES)
- **Resend API** - Email service

### AWS Infrastructure

- **CloudFront** - CDN global
- **S3** - Static site hosting
- **Lambda** - Email processing
- **API Gateway** - Contact endpoint
- **Route 53** - DNS gerenciado pela AWS
- **IAM** - Controle de acesso

---

## 📋 Requirements

- Node.js 18+
- npm
- Git
- AWS CLI (para deploy)
- GitHub Secrets configurados

---

## 🛠️ Local Setup

```bash
# Clone
git clone https://github.com/fagnergs/linear-hub-website-aws.git
cd linear-hub-website-aws

# Install & Run
npm install
npm run dev
# Open http://localhost:3000
```

---

## 📖 Documentação Rápida

| Doc | Propósito |
|-----|----------|
| **[00_START_HERE.md](00_START_HERE.md)** | Guia executivo (LEIA PRIMEIRO!) |
| **[ROUTE53_DNS_SETUP.md](ROUTE53_DNS_SETUP.md)** | Setup Route 53 e nameservers |
| **[REMOVE_OLD_GOOGLE.md](REMOVE_OLD_GOOGLE.md)** | Remover site antigo do Google |
| **[FINAL_CHECKLIST.md](FINAL_CHECKLIST.md)** | Checklist completo + próximos passos |

## 🌍 Languages

- 🇧🇷 Portuguese (default)
- 🇺🇸 English
- 🇪🇸 Spanish

Translation files: `public/locales/{locale}/common.json`

---

## 🌍 Languages

- 🇧🇷 Portuguese (default)
- 🇺🇸 English
- 🇪🇸 Spanish

Translation files: `public/locales/{locale}/common.json`

---

## 📦 Build & Deploy

### Local Development

```bash
# Development server
npm run dev
# Open http://localhost:3000
```

### Production Build

```bash
# Build for static export (required for S3)
npm run build

# Output in: out/ directory
# Files ready for S3 deployment

# Lint code
npm run lint
```

### Deploy to AWS (Automatic)

Push to main branch:
```bash
git push origin main
```

**GitHub Actions** irá automaticamente:
1. Build com `npm run build`
2. Deploy para S3: `linear-hub-website-prod-1765543563`
3. Invalidar CloudFront cache
4. Site atualizado em ~2 minutos!

**Manual Deploy:**
```bash
# AWS CLI command
aws s3 sync out/ s3://linear-hub-website-prod-1765543563/ \
  --delete --cache-control "public, max-age=31536000" \
  --exclude "*.html" --include "*"

# Invalidate CloudFront
aws cloudfront create-invalidation \
  --distribution-id EDQZRUQFXIMQ6 \
  --paths "/*"
```

---

## 🏗️ AWS Architecture

### Services

```
┌─────────────────────────────────────────────────┐
│             CloudFront CDN (Global)             │
│         d1dmp1hz6w68o3.cloudfront.net           │
│     (TLS/HTTPS auto-enabled, cache layer)       │
└────────────┬────────────────────────────────────┘
             │
     ┌───────┴─────────┐
     │                 │
┌────▼──────┐    ┌────▼──────────┐
│  S3 Bucket│    │ Lambda@Edge    │
│  (Origin) │    │ (Cache rules)  │
│   Static  │    │                │
│   HTML/JS │    └────────────────┘
│   CSS/IMG │
└───────────┘

┌────────────────────────────────────────────────┐
│         Route 53 (DNS Management)              │
│    Z01786261P1IDZOECZQA5                       │
│    linear-hub.com.br → CloudFront ALIAS        │
└────────────────────────────────────────────────┘

┌────────────────────────────────────────────────┐
│      API Gateway + Lambda (Email Form)         │
│   POST /contact → Lambda → Resend API Email    │
│      xsp6ymu9u6 → linear-hub-contact-api       │
└────────────────────────────────────────────────┘
```

### Cloud Resources

| Recurso | ID | Status |
|---------|-------|--------|
| CloudFront Distribution | EDQZRUQFXIMQ6 | ✅ Active |
| S3 Bucket | linear-hub-website-prod-1765543563 | ✅ Active |
| Lambda Function | linear-hub-contact-api | ✅ Active |
| API Gateway | xsp6ymu9u6 | ✅ Active |
| Route 53 Hosted Zone | Z01786261P1IDZOECZQA5 | ✅ Active |
| IAM User | linear-hub-deployer | ✅ Active |

---

## 🏗️ Project Structure

```
components/          # React components
├── layout/         # Header, Footer, Layout
└── sections/       # Hero, About, Services, Projects, Clients, Contact

pages/              # Next.js routes & API
├── api/contact.ts  # Lambda endpoint (via API Gateway)
└── index.tsx       # Main page

public/
├── locales/        # Translation JSON files
├── images/         # Static assets
├── sitemap.xml     # SEO sitemap
└── robots.txt      # SEO robots

lib/i18n.tsx        # i18n provider & hooks

styles/             # Global CSS
```

---

## 🔧 Configuration

### Environment Variables (GitHub Secrets)

Já configurados em GitHub:
```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_REGION
AWS_S3_BUCKET
AWS_CLOUDFRONT_DISTRIBUTION_ID
RESEND_API_KEY
CONTACT_EMAIL
```

**Local Development (.env.local):**
```bash
# Create file .env.local (not committed to git)
RESEND_API_KEY=re_your_api_key_here
NEXT_PUBLIC_SITE_URL=http://localhost:3000
```

### AWS Services Configuration

**CloudFront:** Cache headers automáticos
- HTML: 5 minutos (max-age=300)
- JS/CSS/Images: 1 ano (max-age=31536000)

**Route 53:** ALIAS records
- `linear-hub.com.br` → `d1dmp1hz6w68o3.cloudfront.net`
- `www.linear-hub.com.br` → `d1dmp1hz6w68o3.cloudfront.net`

**Lambda:** Node.js 20.x
- Memory: 256MB
- Timeout: 30 segundos
- Environment: Resend API key
---

## 🚀 Production URLs

| Ambiente | URL |
|----------|-----|
| **Production (CloudFront)** | https://d1dmp1hz6w68o3.cloudfront.net/ |
| **Production (Route 53)** | https://linear-hub.com.br/ (após DNS propagar) |
| **Local Development** | http://localhost:3000 |

---

## 📞 Support & Troubleshooting

### DNS não funciona?

```bash
# Verificar nameservers
nslookup linear-hub.com.br

# Limpar cache DNS (macOS)
sudo dscacheutil -flushcache

# Online check
https://www.whatsmydns.net/
```

### Site faltando CSS?

```bash
# Limpar CloudFront cache (AWS CLI)
aws cloudfront create-invalidation \
  --distribution-id EDQZRUQFXIMQ6 \
  --paths "/*"

# Limpar cache do navegador: Ctrl+Shift+Del
```

### Email de contato não funciona?

```bash
# Verificar Lambda logs
aws lambda tail linear-hub-contact-api --follow

# Verificar Resend API
# https://dashboard.resend.com/
```

---

## 📱 Responsive Design

Otimizado para:
- Desktop (1920px+)
- Laptop (1024px - 1919px)
- Tablet (768px - 1023px)
- Mobile (< 768px)

---

## 🎨 Features

✅ Performance otimizado com SSG  
✅ Animações suaves & transições  
✅ Suporte multilíngue (PT, EN, ES)  
✅ Formulário de contato funcional  
✅ Totalmente acessível (A11y)  
✅ SEO otimizado (sitemap, robots.txt)  
✅ HTTPS/TLS automático (CloudFront)  
✅ Deploy automático (GitHub Actions)  
✅ Cache inteligente (CloudFront CDN)  
✅ Email automático (Resend API)  

---

## 💰 Custos AWS

| Serviço | Custo/mês |
|---------|-----------|
| CloudFront CDN | ~$2 |
| S3 Storage | ~$1 |
| Lambda (contatos) | ~$2 |
| Route 53 | ~$1 |
| **TOTAL** | **~$6/mês** |

**Crédito AWS:** $200 = 30+ meses grátis! 💰

---

## 📚 Documentação Completa

- **[00_START_HERE.md](00_START_HERE.md)** - Guia executivo (COMECE AQUI!)
- **[ROUTE53_DNS_SETUP.md](ROUTE53_DNS_SETUP.md)** - Setup Route 53
- **[REMOVE_OLD_GOOGLE.md](REMOVE_OLD_GOOGLE.md)** - Google Search Console
- **[FINAL_CHECKLIST.md](FINAL_CHECKLIST.md)** - Checklist completo
- **[PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)** - Resumo técnico
- **[DEPLOY.md](DEPLOY.md)** - Instruções de deploy

---

## 📧 Contato

**Linear Hub**
- Email: contato@linear-hub.com.br
- Website: https://linear-hub.com.br
- Location: Jaguariúna - SP, Brazil

---

## 📄 License

© 2024 Linear Hub. Todos os direitos reservados.

---

**Status:** ✅ Production Ready  
**Última atualização:** 2025-12-12  
**Versão:** 1.0  
**Deploy:** Automático via GitHub Actions  

**Próximo passo:** Ver [00_START_HERE.md](00_START_HERE.md) para continuar! 🚀
# Formulário de Contato Refatorado - Deploy Simplificado
