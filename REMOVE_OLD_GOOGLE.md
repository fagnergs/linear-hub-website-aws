# 🗑️ Remover Site Antigo do Google

**Objetivo:** Remover versão antiga (Firebase) do Google Search Console
**Tempo:** 5 minutos
**Status:** Site novo já em produção em linear-hub.com.br

---

## 📋 2 Opções de Remoção

---

## OPÇÃO 1: Remoção Temporária (Recomendado)

**Duração:** 6 meses (depois volta a ser indexado se você quiser)

### Passo 1: Acessar Google Search Console

1. Vá para: https://search.google.com/search-console
2. Faça login com sua conta Google
3. Selecione a propriedade **da versão antiga** (Firebase)

### Passo 2: Solicitar Remoção

1. Menu à esquerda: **"Remoções"** ou **"Removals"**
   (Pode estar em "Ações" → "Remoções")

2. Clique em **"Criar solicitação de remoção"** ou **"Request removal"**

3. Na caixa de diálogo, você tem 2 opções:
   - **Remove this URL**: Remove apenas uma URL
   - **Remove all URLs from this site**: Remove tudo

4. **Recomendado:** Selecione **"Remove all URLs from this site"**
   (Esto remove a versão antiga completamente)

5. Clique em **"Solicitar remoção"** ou **"Request removal"**

### Passo 3: Confirmação

- Verá uma mensagem de sucesso
- Remoção começa em algumas horas
- Máximo 6 meses

---

## OPÇÃO 2: Remoção Permanente

**Duração:** Permanente (não volta)

### Passo 1: Remover a propriedade completamente

1. No **Google Search Console**, clique no **ícone de engrenagem** ⚙️
2. Selecione **"Settings"** ou **"Configurações"**
3. Procure por **"Property settings"** ou **"Configurações de propriedade"**
4. Scroll até o final da página
5. Clique em **"Remove property"** ou **"Remover propriedade"**
6. Confirme a deleção

**Efeito:** Propriedade deletada completamente do Google Search Console

---

## ✅ PASSO 3: Adicionar Novo Site ao Google

### 3.1 Adicionar Propriedade

1. **Google Search Console**
2. Clique em **"+ Property"** ou **"+ Propriedade"**
3. Selecione **"Domain"** (não URL)
4. Digite: `linear-hub.com.br`
5. Clique em **"Continue"**

### 3.2 Verificação via DNS

Google pedirá verificação. Ele dará um código tipo:

```
google-site-verification=xxxxxxxxxxxxxxxxxxxxx
```

**Você já pode usar AWS Route 53 para isso!**

1. Vá para: https://console.aws.amazon.com/route53/
2. Clique em "Hosted zones"
3. Clique em "linear-hub.com.br"
4. Clique em "Create record"
5. Preencha:
   ```
   Name: linear-hub.com.br (ou deixar vazio)
   Type: TXT
   Value: google-site-verification=xxxxxxxxxxxxxxxxxxxxx (COMPLETO!)
   TTL: 300
   ```
6. Clique em "Create records"

**Volta ao Google Search Console:**
7. Clique em **"Verify"**
8. Aguarde 5-30 minutos

### 3.3 Enviar Sitemap

Após verificação bem-sucedida:

1. **Google Search Console** → Menu "Sitemaps"
2. Clique em **"Add/test sitemap"**
3. Digite: `https://linear-hub.com.br/sitemap.xml`
4. Clique em **"Submit"**

Google começará a indexar o site novo! 🎉

---

## 🔍 Monitoramento Pós-Remoção

### Verificar Status

1. **Google Search Console** (nova propriedade)
2. Menu: **"Coverage"** ou **"Cobertura"**
3. Observe:
   - Valid pages (URLs indexadas)
   - Errors
   - Warnings

### Esperado nos Primeiros Dias

- ⏳ Primeiras 24h: Site descoberto
- ⏳ 1-3 dias: Primeiras URLs indexadas
- ⏳ 1-7 dias: Completa indexação
- ✅ 7+ dias: Indexação estável

---

## 📝 Checklist Final

- [ ] Remoção solicitada (opção 1 ou 2)
- [ ] Novo domínio adicionado ao Google Search Console
- [ ] TXT record criado no Route 53 para verificação
- [ ] Propriedade verificada no Google
- [ ] Sitemap enviado
- [ ] Aguardando indexação (1-7 dias)

---

## 🚀 Você Conquistou!

✅ Site migrado de Firebase para AWS
✅ DNS gerenciado por Route 53
✅ Site online em linear-hub.com.br
✅ Google atualizado

**Site em produção!** 🎉

---

## 📞 Referência Rápida

**Google Search Console:**
https://search.google.com/search-console

**AWS Route 53:**
https://console.aws.amazon.com/route53/

**Seu Site:**
https://linear-hub.com.br/

**Sitemap:**
https://linear-hub.com.br/sitemap.xml

---

**Status:** ✅ Site em produção
**Próximo:** Monitorar indexação do Google (1-7 dias)
