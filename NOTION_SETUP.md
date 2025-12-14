# 🚀 Integração Notion - Passo a Passo Completo

**Status atual:** O código está 100% pronto! Falta apenas configurar as credenciais no Notion e no GitHub.

---

## 📋 CHECKLIST DO QUE PRECISA FAZER:

### ✅ PASSO 1: Criar Notion Integration (App)
- [ ] Ir para: https://www.notion.so/my-integrations
- [ ] Clique em **"New integration"**
- [ ] Nome: `linear-hub-contact-form`
- [ ] Logo: (opcional)
- [ ] Capabilities:
  - [x] Read content
  - [x] Update content
  - [x] Insert content
- [ ] Clique em **"Submit"**
- [ ] Copie o **Internal Integration Token** (começará com `ntion_`)
- [ ] ⚠️ **GUARDE ESTE TOKEN COM SEGURANÇA**

---

### ✅ PASSO 2: Criar Database de Contatos no Notion
1. **Abra seu Notion workspace**
2. **Crie uma nova página** com nome: `Contatos`
3. **Crie uma Database** dentro desta página com as seguintes propriedades:

#### Propriedades obrigatórias:
| Propriedade | Tipo | Descrição |
|------------|------|-----------|
| **Name** | Title | Nome do contato (principal) |
| **Email** | Email | Email do contato |
| **Company** | Rich Text | Empresa do contato |
| **Subject** | Rich Text | Assunto da mensagem |
| **Message** | Rich Text | Corpo da mensagem |
| **Created** | Date | Data de criação |
| **Status** | Select | Status do contato (opções: `new`, `responded`, `archived`) |

4. **Copie o Database ID:**
   - Abra a Database
   - Na URL: `https://notion.so/workspace-name/DATABASE_ID?v=VIEW_ID`
   - O `DATABASE_ID` é a sequência de números/letras após a slash

---

### ✅ PASSO 3: Compartilhar Database com Integration

1. **Abra a Database de Contatos**
2. **Clique em Share** (canto superior direito)
3. **Clique em "Invite"**
4. **Procure por:** `linear-hub-contact-form` (sua integration)
5. **Selecione a Integration**
6. **Dê permissão de Edit**
7. **Clique em "Invite"**

---

### ✅ PASSO 4: Adicionar Secrets no GitHub

Vá para: **GitHub → Settings → Secrets and variables → Actions**

Adicione 2 novos secrets:

#### Secret 1: `NOTION_API_KEY`
- **Name:** `NOTION_API_KEY`
- **Value:** Cole o Internal Integration Token (aquele que começava com `ntion_`)

#### Secret 2: `NOTION_CONTACTS_DATABASE_ID`
- **Name:** `NOTION_CONTACTS_DATABASE_ID`
- **Value:** Cole o Database ID que você copiou no Passo 2.4
- **Formato:** Apenas a sequência de 32 caracteres (sem hífens nem espaços)

---

### ✅ PASSO 5: Verificar Variáveis de Ambiente

O arquivo `.env.example` já contém as variáveis. Verifique:

```bash
NOTION_API_KEY=ntion_your_api_key_here
NOTION_CONTACTS_DATABASE_ID=your_contacts_database_id_here
```

---

### ✅ PASSO 6: Testar a Integração

1. **Acione o workflow de deploy:**
   - Faça um pequeno commit e push para `main`
   - O GitHub Actions sincronizará automaticamente os secrets

2. **Teste o formulário:**
   - Abra seu site: `https://linear-hub.com.br` (ou seu domínio)
   - Preencha o formulário de contato
   - Submeta

3. **Verificar resultados:**
   - ✅ **Email** recebido (via Resend)
   - ✅ **Slack** notificado (#contacts)
   - ✅ **Linear** task criada (projeto LWS)
   - ✅ **Notion** page criada na database de contatos

---

## 🔍 TROUBLESHOOTING

### ❌ "Notion credentials not configured"
**Causa:** `NOTION_API_KEY` ou `NOTION_CONTACTS_DATABASE_ID` não estão em GitHub Secrets  
**Solução:** Volte ao **PASSO 4** e verifique se os secrets foram adicionados corretamente

### ❌ "Invalid database ID"
**Causa:** Database ID copiado com caracteres extras (hífens, espaços)  
**Solução:** Copie novamente apenas a sequência alfanumérica de 32 caracteres

### ❌ "Unauthorized access to database"
**Causa:** A Integration não foi compartilhada com a Database  
**Solução:** Volte ao **PASSO 3** e execute novamente

### ❌ "Invalid property name"
**Causa:** Falta alguma propriedade na Database do Notion  
**Solução:** Volte ao **PASSO 2** e recrie todas as 7 propriedades exactamente como mostrado

---

## 📊 O que o Código Faz (já implementado)

```javascript
// O Lambda automaticamente:
1. Recebe o formulário de contato
2. Envia email via Resend
3. Notifica Slack (#contacts)
4. Cria task no Linear (projeto LWS)
5. Registra em Notion database

// Fluxo sem falhas parciais:
- Se Slack falhar → Email ainda é enviado ✅
- Se Linear falhar → Notion ainda registra ✅
- Se Notion falhar → Tudo antes funciona ✅
```

---

## 🎯 RESULTADO FINAL

Após completar todos os passos:

✅ Cada contato do seu site será:
- Enviado por email
- Notificado no Slack
- Registrado como task no Linear
- Armazenado no Notion database

✅ Todas as integrações funcionando em paralelo (não-bloqueantes)

---

## 📚 Referências

- [Notion API Docs](https://developers.notion.com/)
- [Notion Integrations](https://www.notion.so/my-integrations)
- [GitHub Secrets](https://github.com/settings/secrets/actions)

---

**Próximo passo:** Faça os passos 1-6 acima e depois confirme comigo! 🚀
