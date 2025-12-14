# 🔄 Resetar Integração Notion - Guia Completo

## 🔴 Problema Atual

Mesmo com o novo token, a API Notion retorna:
```
Status: 401
Message: "API token is invalid."
```

**Causa provável:** A integração Notion foi deletada ou revogada da sua conta.

---

## ✅ Solução: Criar Nova Integração Notion do Zero

### **PASSO 1: Deletar Integração Antiga (Opcional)**

Se ainda existir a integração antiga no seu Notion:

1. Acesse: https://www.notion.so/profile/integrations/connected-apps
2. Procure por "Linear Hub" ou similar
3. Clique em **Settings** ou **...** → **Disconnect**
4. Confirme deletar

---

### **PASSO 2: Criar Nova Integração Notion**

1. Acesse: https://www.notion.so/my-integrations
   - Ou: https://developers.notion.com/docs/create-a-notion-app

2. Clique em **"+ New integration"**

3. Preencha:
   - **Name:** `Linear Hub`
   - **Description:** `Integração para enviar contatos do website para Notion`
   - **Logo:** (opcional)

4. Na aba **Capabilities**, marque:
   - ✅ **Read content**
   - ✅ **Update content**  
   - ✅ **Insert content**

5. Clique em **Submit** ou **Create integration**

6. Você será levado a uma página com:
   - **Integration ID**
   - **Internal Integration Token** (começa com `ntn_`)

---

### **PASSO 3: Copiar o Token**

1. Procure por **"Internal Integration Token"** ou **"Secret"**
2. Clique em **Show** ou **Reveal**
3. Copie o token completo (ex: `ntn_273775151365XXXXXXXXXXXXX`)
4. **Guarde em local seguro** (você vai precisar)

---

### **PASSO 4: Conectar Integração ao Database**

1. Abra o seu Notion workspace
2. Navegue até: **Linear Hub Website → Contatos** (ou o nome do seu database)
3. Clique em **Adicionar conexão** ou **⋯** → **Connections**
4. Procure por **"Linear Hub"** (a integração que você criou)
5. Clique em **Connect** ou **Allow access**

**⚠️ IMPORTANTE:** A integração precisa ter **Edit** permission no database!

---

### **PASSO 5: Atualizar GitHub Secret**

```bash
gh secret set NOTION_API_KEY --body "seu_token_aqui"
```

**Exemplo:**
```bash
gh secret set NOTION_API_KEY --body "ntn_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
```

---

### **PASSO 6: Sincronizar com Lambda**

```bash
gh workflow run sync-secrets-to-lambda.yml
```

Aguarde 30-60 segundos para sincronizar.

---

### **PASSO 7: Verificar Sincronização**

```bash
aws lambda get-function-configuration --function-name linear-hub-contact-api \
  --query 'Environment.Variables.NOTION_API_KEY'
```

Deve retornar seu novo token.

---

### **PASSO 8: Testar**

```bash
node test-all-integrations.js https://xsp6ymu9u6.execute-api.us-east-1.amazonaws.com/prod/contact
```

**Esperado:**
- ✅ HTTP 200 OK
- ✅ Email ID retornado
- Uma nova página deve aparecer em Notion → Contatos database

---

### **PASSO 9: Verificar CloudWatch Logs (se falhar)**

```bash
aws logs describe-log-streams \
  --log-group-name /aws/lambda/linear-hub-contact-api \
  --order-by LastEventTime \
  --descending \
  --max-items 1
```

Copie o `logStreamName` e execute:

```bash
aws logs get-log-events \
  --log-group-name /aws/lambda/linear-hub-contact-api \
  --log-stream-name "2025/12/14/[$LATEST]XXXXX" \
  --output text | grep -i notion
```

---

## 🔍 Troubleshooting

### ❌ Erro: "API token is invalid"
- Token foi revogado ou integração foi deletada
- Recrie a integração (passos acima)

### ❌ Erro: "Cannot find database"
- Verifique `NOTION_CONTACTS_DATABASE_ID` em GitHub Secrets
- Confirme que o database existe em Notion

### ❌ Erro: "Integration has insufficient capabilities"
- A integração foi criada sem os Capabilities corretos
- Delete e recrie marcando: Read + Update + Insert

### ❌ Database não foi atualizado após teste bem-sucedido
- A integração não tem permissão de **Edit** no database
- Vá em Notion → Database → Connections → Linear Hub → Upgrade permissão

---

## 📋 Checklist Final

- [ ] Nova integração criada em Notion
- [ ] Token copiado e seguro
- [ ] GitHub Secret atualizado com novo token
- [ ] Workflow sincronização executado
- [ ] Lambda atualizado com novo token (verificado)
- [ ] Integração conectada ao database Contatos
- [ ] Integração tem Edit permission no database
- [ ] Teste executado com sucesso
- [ ] Página apareceu em Notion database

---

## 🆘 Ainda Não Funcionou?

1. Verifique os logs CloudWatch (vide Passo 9)
2. Confirme permissões no database (Edit)
3. Confirme estrutura de properties no database (vide abaixo)

### Properties Necessárias no Database Notion:

| Property | Type | Obrigatório |
|----------|------|-----------|
| Name | Title | ✅ |
| Email | Email | ✅ |
| Company | Text | ✅ |
| Subject | Text | ✅ |
| Message | Rich Text | ✅ |
| Created | Date | ✅ |
| Status | Select | ❌ |

Se faltar alguma property, o Notion retorna erro 400. Adicione no database.

---

## 📞 Próximas Etapas

Após completar todos os passos acima e o teste passar:

1. Remova o documento anterior `NOTION_FIX_TOKEN.md`
2. Verifique todas as 4 integrações funcionando
3. Documente os tokens em local seguro

🚀 **Você está perto do sucesso!**
