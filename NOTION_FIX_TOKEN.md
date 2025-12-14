# ❌ Notion Token Expirado/Inválido - Solução

## Problema Encontrado

Via CLI CloudWatch logs, encontrei o erro:

```
Status: 401
Message: "API token is invalid."
```

**Causa:** O token Notion em `NOTION_API_KEY` expirou ou é inválido.

Token atual (inválido):
```
ntn_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

---

## ✅ Solução: Regenerar Token Notion

### Passo 1: Acessar Notion Settings

1. Acesse: https://www.notion.so/profile/integrations
2. Ou clique em seu avatar → **Settings** → **Integrations** → **My connections**

### Passo 2: Encontrar a Integração "Linear Hub"

- Procure pela integração que você criou (provavelmente chamada "Linear Hub" ou similar)
- Se não encontrar, você precisa criar uma nova:
  1. Clique em **"Develop your own integrations"**
  2. Clique em **"New integration"**
  3. Nome: `Linear Hub`
  4. Capabilities necessárias:
     - ✅ Read content
     - ✅ Update content
     - ✅ Insert content

### Passo 3: Copiar o Novo Token

- Clique na integração
- Procure por **"Internal Integration Token"** ou **"Secret"**
- Copie o novo token (começa com `ntn_`)

### Passo 4: Atualizar GitHub Secrets

```bash
gh secret set NOTION_API_KEY --body "seu_novo_token_aqui"
```

Substitua `seu_novo_token_aqui` pelo token que você copiou.

### Passo 5: Sincronizar com Lambda

O token será sincronizado automaticamente na próxima execução do workflow `sync-secrets-to-lambda.yml`.

Ou force manualmente:
```bash
# Verificar se o workflow existe
gh workflow list

# Executar o workflow manualmente
gh workflow run sync-secrets-to-lambda.yml
```

### Passo 6: Testar

Após atualizar, execute o teste:

```bash
node test-all-integrations.js https://xsp6ymu9u6.execute-api.us-east-1.amazonaws.com/prod/contact
```

---

## 🔍 Alternativa: Verificar Token Atual em Notion

Se você acha que o token ainda é válido, pode estar **revogado**. Verifique:

1. Acesse Notion Settings → Integrations
2. Clique na sua integração
3. Se vir um botão **"Regenerate secret"**, clique nele
4. Copie a nova chave

---

## 📝 Dúvidas Comuns

**P: Meu integração desapareceu?**
A: Notion pode ter removido integrações inativas. Crie uma nova.

**P: Qual é o escopo correto da integração?**
A: Mínimo necessário:
- `Read` (ler database)
- `Update` (atualizar páginas)
- `Insert` (criar páginas)

**P: O token tem limite de tempo?**
A: Tokens Notion não expiram por si só, mas podem ser revogados manualmente ou se a integração for deletada.

---

## 🎯 Próximas Passos

1. Regenere o token em Notion
2. Atualize o GitHub Secret
3. Espere o workflow sincronizar (ou force)
4. Execute `test-all-integrations.js` novamente
5. Verifique CloudWatch logs para confirmar HTTP 200 + success

Qualquer dúvida, relate aqui! 🚀
