# 🔴 Notion 401 - Token Inválido Persistente

## Problema

Mesmo depois de sincronizar o novo token, Notion continua retornando:
```
Status: 401
Message: "API token is invalid."
```

---

## ✅ Diagnóstico em Notion

### **PASSO 1: Verificar se a Integração Ainda Existe**

1. Acesse: https://www.notion.so/profile/integrations
2. Procure por **"Linear Hub"** na lista de integrações
3. Se **NÃO aparecer**, a integração foi deletada
4. Se **aparecer**, clique nela e procure por:
   - Internal Integration Token
   - Status da integração

### **PASSO 2: Verificar se está Conectada ao Database**

1. Abra seu Notion workspace
2. Vá para: **Linear Hub Website → Contatos** database
3. Clique em **⋯** (três pontos) → **Connections**
4. Procure por **"Linear Hub"** 
5. Se **NÃO aparecer**: A integração foi desconectada
6. Se **aparecer com erro**: Há problema de permissão

### **PASSO 3: Verificar o Token**

1. Em https://www.notion.so/profile/integrations
2. Clique em **"Linear Hub"**
3. Procure por **"Internal Integration Token"** ou **"Secret"**
4. Clique em **"Show"** ou **"Reveal"**
5. **Compare com o que você enviou:**
   ```
   ntn_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   ```
6. Se **forem diferentes**, o token que você forneceu está **EXPIRADO ou foi regenerado**

---

## 🔄 Se o Token for Diferente

Se você descobrir que o token em Notion é **diferente** do que você enviou:

1. **Copie o token NOVO de Notion**
2. **Execute no terminal:**
   ```bash
   gh secret set NOTION_API_KEY --body "seu_novo_token_aqui"
   ```
3. **Sincronize com Lambda:**
   ```bash
   gh workflow run sync-secrets-to-lambda.yml
   ```
4. **Aguarde 30-60 segundos**
5. **Teste novamente:**
   ```bash
   node test-all-integrations.js https://xsp6ymu9u6.execute-api.us-east-1.amazonaws.com/prod/contact
   ```

---

## 🔄 Se a Integração Desapareceu

Se a integração não aparece em Notion:

1. **Crie uma integração NOVA:**
   - Vá para https://www.notion.so/my-integrations
   - Clique em **"+ New integration"**
   - Nome: `Linear Hub`
   - Capabilities: Read + Update + Insert
   - **Copie o novo token**

2. **Conecte ao database:**
   - Abra seu database Contatos
   - Clique em **⋯** → **Connections**
   - Procure por **"Linear Hub"** (a nova)
   - Clique em **Connect**

3. **Atualize o token:**
   ```bash
   gh secret set NOTION_API_KEY --body "novo_token"
   gh workflow run sync-secrets-to-lambda.yml
   ```

4. **Teste novamente**

---

## ❌ Se a Integração Perdeu Permissão

Se aparecer em Connections mas com erro/lock:

1. **Clique em "Linear Hub"** em Connections
2. **Procure por opção de "Edit permissions" ou "Upgrade"**
3. **Certifique que tem:**
   - ✅ Read
   - ✅ Update  
   - ✅ Insert

4. **Se não conseguir atualizar:**
   - Desconecte a integração
   - Aguarde 5 segundos
   - Reconecte

---

## 📋 Checklist

- [ ] Integração "Linear Hub" existe em https://www.notion.so/profile/integrations
- [ ] Integração está conectada ao database Contatos
- [ ] Token em Notion **matches** com o que você forneceu
- [ ] Integração tem permissão de Edit no database
- [ ] GitHub Secret foi atualizado (se token era diferente)
- [ ] Workflow de sincronização foi executado
- [ ] Lambda foi atualizado com novo token

---

## 📞 Próximos Passos

1. **Faça o diagnóstico acima**
2. **Relate qual é o problema encontrado:**
   - Token é diferente?
   - Integração desapareceu?
   - Integração perdeu permissão?
3. **Forneça o token correto** (se for diferente)
4. **Eu vou atualizar e testar**

🚀 Me avisa o resultado!
