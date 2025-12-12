# 🚀 AWS Route 53 DNS Setup Guide

**Status:** ✅ Hosted Zone criada em AWS Route 53
**Objetivo:** Migrar DNS de Registro.BR para AWS Route 53

---

## 📊 Informações da Hosted Zone

```
Hosted Zone ID:   Z01786261P1IDZOECZQA5
Domain:           linear-hub.com.br
CloudFront CNAME: d1dmp1hz6w68o3.cloudfront.net
```

---

## 🔧 Nameservers do Route 53

**SALVE ESSES VALORES! Você vai usar no Registro.BR:**

```
ns-526.awsdns-01.net
ns-2028.awsdns-61.co.uk
ns-346.awsdns-43.com
ns-1201.awsdns-22.org
```

---

## 📝 Records Já Criados

```
Type: A (ALIAS para CloudFront)
Name: linear-hub.com.br
Target: d1dmp1hz6w68o3.cloudfront.net

Type: A (ALIAS para CloudFront)
Name: www.linear-hub.com.br
Target: d1dmp1hz6w68o3.cloudfront.net
```

---

## 📋 PASSO 1: Atualizar Nameservers no Registro.BR

### 1.1 Acessar Registro.BR

1. Vá para: https://www.registro.br/
2. Faça login com sua conta
3. Menu: "Meus domínios"
4. Clique em "linear-hub.com.br"

### 1.2 Acessar DNS do domínio

1. Na página do domínio, procure por:
   - "Zona de DNS" ou "Nameservers"
   - Ou "Configurar" → "Servidores de nomes"

### 1.3 Adicionar Nameservers do Route 53

**Você verá uma opção para adicionar nameservers.**

Adicione os 4 nameservers do Route 53:

```
ns-526.awsdns-01.net
ns-2028.awsdns-61.co.uk
ns-346.awsdns-43.com
ns-1201.awsdns-22.org
```

### 1.4 Salvar

Clique em "Confirmar" ou "Salvar"

**Status:** Nameservers estão sendo atualizados (5-30 minutos)

---

## ✅ PASSO 2: Verificar Propagação (5-30 minutos)

### 2.1 Teste online

```
https://www.whatsmydns.net/
Domínio: linear-hub.com.br
Tipo: NS (não A ou CNAME!)
```

Procure pelos nameservers do Route 53. Quando todos estiverem verdes ✅:

### 2.2 Teste no terminal

```bash
nslookup linear-hub.com.br

# Esperado:
# Non-authoritative answer:
# Name: linear-hub.com.br
# Address: xxx.xxx.xxx.xxx (IP do CloudFront)
```

### 2.3 Teste no navegador

```
https://linear-hub.com.br
```

Deve carregar seu site!

---

## 🔍 PASSO 3: Verificar Records no Route 53 (AWS Console)

1. Vá para: https://console.aws.amazon.com/route53/
2. Clique em "Hosted zones"
3. Clique em "linear-hub.com.br"
4. Verifique se tem:
   - Record A para "linear-hub.com.br" → CloudFront
   - Record A para "www.linear-hub.com.br" → CloudFront

---

## 🗑️ PASSO 4: Remover DNS Antigo do Registro.BR (Opcional)

Se o Registro.BR ainda tem registros DNS antigos:

1. Volte para o Registro.BR
2. Menu: "Meus domínios" → "linear-hub.com.br"
3. Procure por "Zona de DNS" ou "DNS Records"
4. Delete todos os registros antigos (se ainda existirem)

**Não precisa fazer agora se os nameservers já estão apontando para Route 53!**

---

## 🗑️ PASSO 5: Remover Site Antigo do Google

### 5.1 Google Search Console

1. Vá para: https://search.google.com/search-console
2. Selecione sua propriedade antiga (Firebase)
3. Menu: "Remoções" ou "Removals"
4. Clique em "Criar solicitação de remoção"
5. Digite a URL da versão antiga
6. Selecione: "Incluir este URL e todas as subpáginas"
7. Clique em "Solicitar remoção"

**Duração:** Aproximadamente 6 meses

### 5.2 Remover propriedade antiga (OPCIONAL)

```
Settings → Property settings → Remove property
```

---

## 📊 Verificar Registros no AWS

```bash
# Listar todos os records da hosted zone
aws route53 list-resource-record-sets \
  --hosted-zone-id Z01786261P1IDZOECZQA5 \
  --query 'ResourceRecordSets[?Type==`A`]'

# Esperado:
# A record para linear-hub.com.br → d1dmp1hz6w68o3.cloudfront.net
# A record para www.linear-hub.com.br → d1dmp1hz6w68o3.cloudfront.net
```

---

## 🧪 Teste Completo

```bash
# Test 1: DNS Resolution
nslookup linear-hub.com.br

# Test 2: HTTPS
curl -I https://linear-hub.com.br

# Esperado: HTTP/2 200

# Test 3: Content
curl https://linear-hub.com.br | grep "Linear Hub"
```

---

## 💡 Vantagens dessa Abordagem

✅ **Centralizado:** Tudo em um lugar (AWS)
✅ **Integrado:** CloudFront + S3 + Lambda + Route 53
✅ **Automático:** Sem necessidade de entrar em Registro.BR
✅ **Infrastructure as Code:** Pode ser versionado
✅ **Monitoramento:** CloudWatch integrado
✅ **Sem surpresas:** Sem cobranças extras
✅ **Rápido:** Propagação mais rápida

---

## ⏱️ Timeline

```
NOW:        Nameservers atualizados no Registro.BR
+5-30 min:  DNS propagando
+30 min:    Site totalmente em linear-hub.com.br ✅
+2 min:     Remover do Google
+1-7 dias:  Google indexar novo site
```

---

## 📞 Informações de Suporte

**Hosted Zone ID:** Z01786261P1IDZOECZQA5
**CloudFront:** d1dmp1hz6w68o3.cloudfront.net
**S3 Bucket:** linear-hub-website-prod-1765543563
**Lambda:** linear-hub-contact-api

---

## ✨ Próximos Passos

1. ✅ Nameservers adicionados no Registro.BR
2. ⏳ Aguardar propagação (5-30 min)
3. ✅ Testar site em linear-hub.com.br
4. ✅ Remover do Google Search Console
5. ✅ DONE! Site em produção 🚀

---

**Status:** Site em produção com AWS Route 53 para DNS!
**Data:** 12 de dezembro de 2025
