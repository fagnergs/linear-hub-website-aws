# ⚡ QUICK START: DNS + Google em 10 minutos

## 🎯 O que você vai fazer agora

| # | Tarefa | Tempo | Status |
|---|--------|-------|--------|
| 1 | Acessar registrador de domínio | 1 min | ⬜ TODO |
| 2 | Criar CNAME record | 5 min | ⬜ TODO |
| 3 | Verificar propagação DNS | 5-30 min | ⏳ AGUARDANDO |
| 4 | Testar site em linear-hub.com.br | 2 min | ⬜ TODO |
| 5 | Remover URLs antigas do Google | 2 min | ⬜ TODO |
| 6 | Adicionar novo domínio ao Google | 2 min | ⬜ TODO |

---

## 1️⃣ STEP 1: Acessar seu registrador (1 minuto)

**Você registrou o domínio em qual desses?**

### ✅ Registro.br (Brasil)
```
1. Acesse: https://www.registro.br/
2. Login com seu CPF/CNPJ
3. Procure por "Meus dominios"
4. Clique em "linear-hub.com.br"
5. Vá para "Configurar" → "Zona de DNS"
```

### ✅ GoDaddy
```
1. Acesse: https://www.godaddy.com/
2. Login
3. Procure "Meus produtos"
4. Clique em "linear-hub.com.br"
5. Clique em "Gerenciar DNS"
```

### ✅ NameCheap
```
1. Acesse: https://www.namecheap.com/
2. Login
3. "Dashboard" → "Domain List"
4. Clique em "Manage" ao lado de "linear-hub.com.br"
5. Procure "Advanced DNS"
```

### ✅ Hostinger
```
1. Acesse: https://www.hostinger.com/
2. Login
3. "Hospedagem" → "Seus domínios"
4. Clique em "linear-hub.com.br"
5. Procure "Gerenciador de DNS"
```

---

## 2️⃣ STEP 2: Criar/Editar CNAME Record (5 minutos)

### Procure por "Adicionar Record" ou "Add Record"

**Preencha com:**

```
Host/Name:     linear-hub.com.br  (ou deixar vazio/@)
Type:          CNAME
Value/Target:  d1dmp1hz6w68o3.cloudfront.net
TTL:           3600 (ou padrão)
```

**Clique em "Save" ou "Confirmar"**

### ⚠️ Se seu registrador diz "CNAME não permitido na raiz"

**Use ALIAS ao invés:**
```
Host:          linear-hub.com.br
Type:          ALIAS ou ANAME
Value:         d1dmp1hz6w68o3.cloudfront.net
TTL:           3600
```

---

## 3️⃣ STEP 3: Verificar Propagação DNS (5-30 minutos)

### Método 1: Teste Online (Recomendado)
1. Vá para: https://www.whatsmydns.net/
2. Digite: `linear-hub.com.br`
3. Selecione: `CNAME`
4. Clique em "Search"
5. Observe se todos os servidores estão verdes ✅

### Método 2: Terminal
```bash
# Mac ou Linux
nslookup linear-hub.com.br

# Ou
dig linear-hub.com.br CNAME
```

Esperado ver:
```
linear-hub.com.br CNAME d1dmp1hz6w68o3.cloudfront.net
```

### Método 3: Navegador
```
Abra: https://linear-hub.com.br

Se carregar = propagação concluída ✅
```

---

## 4️⃣ STEP 4: Testar Site (2 minutos)

### Checklist rápido:
```bash
# Teste no terminal:
curl -I https://linear-hub.com.br

# Esperado:
# HTTP/2 200
# Content-Type: text/html
```

### Teste no navegador:
- [ ] Abra: https://linear-hub.com.br
- [ ] Página carrega completamente?
- [ ] CSS/estilos visíveis?
- [ ] Teste formulário de contato
- [ ] Teste idiomas (PT/EN/ES)

---

## 5️⃣ STEP 5: Remover do Google (2 minutos)

### 5.1 Remover URLs antigas

```
1. Vá para: https://search.google.com/search-console
2. Selecione seu domínio antigo (Firebase)
3. Menu → "Remoções" ou "Removals"
4. Clique em "Criar solicitação de remoção"
5. Digite URL da versão antiga
6. Selecione "Incluir este URL e todas as subpáginas"
7. Clique em "Solicitar remoção"
```

**Duração:** 6 meses (depois volta)

### 5.2 Remover propriedade antiga (OPCIONAL)

```
1. No Search Console, clique ⚙️ (Settings)
2. "Configurações de propriedade"
3. Scroll até o final
4. "Remover propriedade"
5. Confirme
```

---

## 6️⃣ STEP 6: Adicionar Novo Domínio ao Google (2 minutos)

### 6.1 Adicionar propriedade

```
1. Vá para: https://search.google.com/search-console
2. Clique em "+ Propriedade" ou "Add Property"
3. Selecione "Domain"
4. Digite: linear-hub.com.br
5. Clique em "Continue"
```

### 6.2 Verificar via DNS

Google vai dar um código TXT:

```
1. Copie o código (tipo: google-site-verification=xxxxx)
2. Volte ao seu registrador
3. Crie um novo Record TXT:
   - Type: TXT
   - Name: linear-hub.com.br (ou @)
   - Value: google-site-verification=xxxxx (COMPLETO)
4. Salve
5. Volte ao Google Search Console
6. Clique em "Verify"
```

**Aguarde 5-30 minutos para propagação**

### 6.3 Após verificação

```
1. Envie Sitemap: https://linear-hub.com.br/sitemap.xml
2. Aguarde indexação (pode levar alguns dias)
3. Monitore em Search Console → "Coverage"
```

---

## 📊 Status Checklist

- [ ] CNAME criado no registrador
- [ ] Propagação DNS verificada (whatsmydns.net)
- [ ] Site acessível em https://linear-hub.com.br
- [ ] HTTPS funcionando (cadeado verde)
- [ ] Conteúdo carregando corretamente
- [ ] Formulário de contato testado
- [ ] URLs antigas removidas do Google
- [ ] Novo domínio adicionado ao Google
- [ ] Propriedade verificada via DNS
- [ ] Sitemap enviado ao Google

---

## 🔍 Monitoramento Pós-Deploy

### Diariamente (primeiros 7 dias)
- [ ] Verificar se site está online
- [ ] Checar Google Search Console → "Coverage"
- [ ] Monitora erros de rastreamento

### Semanalmente
- [ ] Verificar Analytics
- [ ] Confirmar emails de contato chegando
- [ ] Testar em diferentes navegadores

---

## 📞 Informações de Suporte Rápido

**CloudFront:** d1dmp1hz6w68o3.cloudfront.net
**S3 Bucket:** linear-hub-website-prod-1765543563
**Lambda:** linear-hub-contact-api
**Region:** us-east-1

---

## ⏱️ Timeline Esperado

```
T+0min:     ← Você está aqui (criar CNAME)
T+5min:     Propagação começando
T+30min:    Propagação na maioria dos servidores
T+1h:       Propagação completa
T+1-7 dias: Google indexa o site
```

---

**Sucesso esperado:** Site totalmente online em linear-hub.com.br em menos de 1 hora! 🚀
