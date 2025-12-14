# 🔍 Verificar ID do Database Notion

## Problema Detectado

O token é válido mas ainda recebe erro 401. Isso pode ser porque:

1. **O ID do database está errado ou sem os hífens**
2. **O database não é o mesmo que a integração foi conectada**

---

## ✅ Como Encontrar o ID Correto

### **PASSO 1: Abrir o Database**

1. Acesse seu Notion: https://www.notion.so
2. Vá para: **Linear Hub Website** → **Contatos** (ou seu database de contatos)

### **PASSO 2: Copiar ID da URL**

A URL será algo como:
```
https://www.notion.so/WORKSPACE_ID/2c965fd3ba8080308a48fdcff898eacf?v=XXXXX
```

Ou assim:
```
https://www.notion.so/2c965fd3ba8080308a48fdcff898eacf
```

O ID é a sequência longa de caracteres.

### **PASSO 3: Formatar o ID com Hífens**

Se o ID for: `2c965fd3ba8080308a48fdcff898eacf`

Deve ficar assim: `2c965fd3-ba80-8030-8a48-fdcff898eacf`

(Padrão UUID: 8-4-4-4-12 caracteres)

---

## 🔄 Atualizar o ID em GitHub Secrets

```bash
gh secret set NOTION_CONTACTS_DATABASE_ID --body "2c965fd3-ba80-8030-8a48-fdcff898eacf"
```

Substitua pelo ID correto com hífens.

---

## 🔄 Sincronizar com Lambda

```bash
gh workflow run sync-secrets-to-lambda.yml
```

Aguarde 30-60 segundos.

---

## ✅ Verificar Sincronização

```bash
aws lambda get-function-configuration \
  --function-name linear-hub-contact-api \
  --query 'Environment.Variables.NOTION_CONTACTS_DATABASE_ID'
```

Deve retornar o ID **COM HÍFENS**.

---

## 🧪 Testar Novamente

```bash
node test-all-integrations.js https://xsp6ymu9u6.execute-api.us-east-1.amazonaws.com/prod/contact
```

---

## 💡 Dica Extra

Para verificar o banco de dados conectado à integração em Notion:

1. Abra o database em Notion
2. Clique em **⋯** → **Connections**
3. Procure por **Linear Hub**
4. Confirme que está na integração correta (deve estar ao lado do database certo)

---

## 📝 Checklist

- [ ] Encontrou o ID correto do database em Notion
- [ ] Formatou com hífens (UUID format: 8-4-4-4-12)
- [ ] Atualizou GitHub Secret com novo ID
- [ ] Executou workflow de sincronização
- [ ] Verificou que Lambda tem o novo ID (com hífens)
- [ ] Executou teste novamente

🚀 Me avisa quando tiver o ID correto!
