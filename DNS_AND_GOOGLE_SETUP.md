# 🌐 Guia: Configurar DNS + Remover do Google

**Status:** ✅ Site online em `https://d1dmp1hz6w68o3.cloudfront.net/`
**Objetivo:** Fazer site acessível em `linear-hub.com.br` e remover versão antiga do Google

---

## 📋 Passo 1: Atualizar DNS (5-10 minutos)

### 1.1 Acessar seu registrador de domínio

Você pode ter registrado seu domínio em um desses registradores:
- **Registro.br** (Brasil)
- **GoDaddy**
- **NameCheap**
- **Hostinger**
- **UOL Host**
- Outro?

### 1.2 Criar/Editar record DNS

**Tipo de record:** `CNAME` ou `ALIAS` (se o registrador oferecer)

| Campo | Valor |
|-------|-------|
| **Nome/Host** | `linear-hub.com.br` (ou deixar vazio/@ para root) |
| **Tipo** | `CNAME` ou `ALIAS` |
| **Destino/Valor** | `d1dmp1hz6w68o3.cloudfront.net` |
| **TTL** | `3600` (padrão, 1 hora) |

### 1.3 Se seu registrador NÃO permite CNAME no domínio raiz

⚠️ Alguns registradores bloqueam CNAME na raiz (`linear-hub.com.br`).

**Solução:** Usar `ALIAS` record (se disponível):
- **Tipo:** `ALIAS` ou `ANAME`
- **Nome:** `linear-hub.com.br`
- **Target:** `d1dmp1hz6w68o3.cloudfront.net`

**Outra solução:** Usar Nameservers (mais complexo)
- Entre em contato se precisar desse caminho

### 1.4 Verificar após salvar

```bash
# Aguarde 5-30 minutos pela propagação
# Depois execute:

nslookup linear-hub.com.br

# Esperado:
# Name: linear-hub.com.br
# Address: xxx.xxx.xxx.xxx (IP do CloudFront)
```

---

## ✅ Passo 2: Verificar Propagação (5-30 minutos)

### 2.1 Teste online

Visite: https://www.whatsmydns.net/

1. Digite: `linear-hub.com.br`
2. Selecione: `CNAME`
3. Clique em "Search"
4. Observe o mapa mundi se "servers are ready" está verde

### 2.2 Teste local

```bash
# No terminal:
dig linear-hub.com.br

# Ou (Mac/Linux):
nslookup linear-hub.com.br

# Esperado (em alguns):
# linear-hub.com.br. 3600 IN CNAME d1dmp1hz6w68o3.cloudfront.net.
```

### 2.3 Teste no navegador

```
https://linear-hub.com.br
```

Se o site carregar = DNS está propagado! 🎉

---

## 🗑️ Passo 3: Remover Versão Antiga do Google (1-2 minutos)

### 3.1 Acessar Google Search Console

1. Vá para: https://search.google.com/search-console
2. Faça login com sua conta Google
3. Selecione a propriedade/domain

### 3.2 Remover URLs antigas do Firebase

1. **Menu lateral:** "Remoções" ou "Removals" (pode estar em "Ações" → "Remoções temporárias")
2. Clique em **"Criar solicitação de remoção"**
3. Digite a URL da versão antiga (ex: `https://linear-hub-website.firebaseapp.com/`)
4. Selecione: **"Incluir este URL e todas as subpáginas"**
5. Clique em **"Solicitar remoção"**

**Duração da remoção:** Aproximadamente 6 meses (Google mantém removida temporariamente)

### 3.3 Remover propriedade antiga (se existir)

Se há uma propriedade separada para o site antigo:

1. No **Search Console**, clique no **ícone de engrenagem** (⚙️)
2. Selecione **"Configurações de propriedade"**
3. Procure por **"Remover propriedade"** (no final)
4. Clique e confirme

---

## 📍 Passo 4: Configurar Novo Site no Google (2 minutos)

### 4.1 Adicionar novo domínio ao Search Console

1. Vá para: https://search.google.com/search-console
2. Clique em **"+ Propriedade"** ou **"Adicionar propriedade"**
3. Selecione **"Domínio"**
4. Digite: `linear-hub.com.br`
5. Clique em **"Continuar"**

### 4.2 Verificar propriedade via DNS

Google pedirá verificação via DNS:

1. Copie o registro TXT fornecido (ex: `google-site-verification=xxxxx`)
2. Vá até seu registrador de domínio
3. Adicione um novo record:
   - **Tipo:** `TXT`
   - **Nome:** `linear-hub.com.br` (ou `@`)
   - **Valor:** `google-site-verification=xxxxx` (cole o valor completo)
4. Salve
5. Volte ao Search Console
6. Clique em **"Verificar"**

**Aguarde:** 5-30 minutos para propagação

### 4.3 Após verificação bem-sucedida

- Envie o sitemap: https://linear-hub.com.br/sitemap.xml
- Configure preferências de site
- Aguarde indexação (alguns dias)

---

## 🧪 Passo 5: Testar Site Completo (2 minutos)

### 5.1 Verificar HTTPS

```bash
curl -I https://linear-hub.com.br
```

Esperado: `HTTP/2 200`

### 5.2 Testar em navegador

- [ ] Acessar: https://linear-hub.com.br
- [ ] Verificar se carrega completamente
- [ ] Testar idiomas (PT/EN/ES)
- [ ] Enviar formulário de contato
- [ ] Verificar se recebe email

### 5.3 Verificar certificate SSL

```bash
openssl s_client -connect linear-hub.com.br:443
```

Esperado: Certificate válido emitido por CloudFront

---

## 📊 Checklist Final

- [ ] DNS record criado (CNAME → CloudFront)
- [ ] Propagação verificada (whatsmydns.net ou nslookup)
- [ ] Site acessível em https://linear-hub.com.br
- [ ] URLs antigas removidas do Google Search Console
- [ ] Novo domínio adicionado ao Google Search Console
- [ ] Propriedade verificada via DNS no Google
- [ ] Sitemap enviado ao Google
- [ ] Teste de acesso completo realizado
- [ ] Formulário de contato testado

---

## 🆘 Troubleshooting

### Site ainda não carrega após 30 minutos

1. Verifique DNS: `nslookup linear-hub.com.br`
2. Confirme CloudFront está ativo: https://console.aws.amazon.com/cloudfront
3. Limpe cache do navegador (Ctrl+Shift+Delete / Cmd+Shift+Delete)

### DNS mostra CNAME mas site não abre

1. Verifique se CloudFront Distribution está `Enabled`
2. Teste direto: https://d1dmp1hz6w68o3.cloudfront.net/
3. Se direto funciona = problema é DNS, aguarde mais tempo

### Email de contato não chega

1. Verifique no AWS Lambda → Logs
2. Confirme Resend API Key está válida
3. Verifique spam/promotions

---

## 📞 Suporte

**CloudFront Domain:** d1dmp1hz6w68o3.cloudfront.net
**S3 Bucket:** linear-hub-website-prod-1765543563
**Lambda Function:** linear-hub-contact-api
**API Gateway:** https://xsp6ymu9u6.execute-api.us-east-1.amazonaws.com/prod/contact

---

**Status:** ✅ Pronto para deployment em produção
**Última atualização:** 12 de dezembro de 2025
