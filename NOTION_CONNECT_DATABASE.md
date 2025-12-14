# 🔗 Conectar Integração ao Database Notion

## O Problema

A integração foi criada com sucesso, mas ainda retorna `401 - API token is invalid`.

**Causa:** A integração precisa ser **conectada/compartilhada** com o seu database Contatos em Notion.

---

## ✅ Solução: Compartilhar Integração com Database

### **PASSO 1: Abrir o Database em Notion**

1. Acesse seu Notion: https://www.notion.so
2. Navegue para o seu workspace: **Linear Hub Website**
3. Abra o database: **Contatos** (ou similar)

### **PASSO 2: Acessar Conexões do Database**

1. Clique no ícone de **⋯** (três pontos) no canto superior direito do database
2. Selecione **Connections** (ou **Add connections**)
3. Você verá uma lista de integrações disponíveis

### **PASSO 3: Conectar a Integração "Linear Hub"**

1. Procure por **"Linear Hub"** na lista de conexões
2. Clique em **Connect** ou **Allow access**
3. Você pode ver opções como:
   - ✅ **Read** (ler dados)
   - ✅ **Update** (atualizar páginas)
   - ✅ **Insert** (criar páginas)
4. **Certifique-se que está marcado como Edit** (ou pelo menos Insert + Update)

### **PASSO 4: Confirmar Conexão**

1. Você deve ver **"Linear Hub"** aparecendo na lista de conexões do database
2. Status deve mostrar: **Connected** ✅

---

## ✅ Verificar Properties do Database

Enquanto está lá, verifique se o database tem TODAS estas properties:

| Property | Type | Nota |
|----------|------|------|
| **Name** | Title | Obrigatória (é a primeira coluna) |
| **Email** | Email | Campo de email |
| **Company** | Text | Texto simples |
| **Subject** | Text | Texto simples |
| **Message** | Rich Text | Texto com formatação |
| **Created** | Date | Data/hora |
| **Status** | Select | Opcional, com opções como "New", "In Progress", "Done" |

**Se faltar alguma property:** Adicione clicando em **+** ao lado das colunas.

---

## 🔄 Após Conectar

1. Aguarde 10-20 segundos para sincronização
2. Volte para o terminal
3. Execute o teste novamente:

```bash
node test-all-integrations.js https://xsp6ymu9u6.execute-api.us-east-1.amazonaws.com/prod/contact
```

4. Verifique CloudWatch logs para confirmar `201 Created` em vez de `401`

---

## 🆘 Ainda Não Funciona?

Se depois de conectar a integração ainda receber 401:

1. **Verifique a URL do database:**
   - Abra o database em Notion
   - Copie a URL da barra de endereços
   - Extraia o ID (32 caracteres após o último `/`)
   - Confirme que matches com `NOTION_CONTACTS_DATABASE_ID` em GitHub Secrets

2. **Revogue e reconecte:**
   - Em Notion, clique em **⋯** → **Connections**
   - Procure por Linear Hub → **Disconnect** ou **Remove**
   - Aguarde 5 segundos
   - Reconecte (passo acima)

3. **Verifique permissões:**
   - A integração precisa estar compartilhada com **Edit** permission mínimo

---

## 📝 Comandos de Verificação

```bash
# Verificar se o token está em Lambda
aws lambda get-function-configuration \
  --function-name linear-hub-contact-api \
  --query 'Environment.Variables.NOTION_API_KEY'

# Verificar Database ID
aws lambda get-function-configuration \
  --function-name linear-hub-contact-api \
  --query 'Environment.Variables.NOTION_CONTACTS_DATABASE_ID'

# Ver logs após conectar
aws logs get-log-events \
  --log-group-name /aws/lambda/linear-hub-contact-api \
  --log-stream-name "STREAM_NAME_AQUI" \
  --output text | grep -i notion
```

---

## ✨ Próximos Passos

1. **Conecte a integração ao database** (passos acima)
2. **Reexecute o teste**
3. **Verifique Notion** - uma nova página deve aparecer em Contatos
4. **Confirme em CloudWatch** - deve mostrar sucesso (sem erro 401)

🚀 Você está muito perto!
