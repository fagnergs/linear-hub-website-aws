# 🔍 NOTION TROUBLESHOOTING CHECKLIST

## Possíveis Problemas:

### 1️⃣ **Credenciais Faltando**
- [ ] Verificar se `NOTION_API_KEY` está em GitHub Secrets
- [ ] Verificar se `NOTION_CONTACTS_DATABASE_ID` está em GitHub Secrets
- [ ] Confirmar que o workflow `sync-secrets-to-lambda.yml` rodou com sucesso

### 2️⃣ **Database ID Inválido**
- [ ] Database ID deve ser **32 caracteres alfanuméricos** (sem hífens)
- [ ] Exemplo correto: `abc123def456789ghi101112jk131415`
- [ ] ❌ Errado: `abc123de-f456-7890-ghi1-01112jk13141` (com hífens)

### 3️⃣ **Propriedades da Database**
A database do Notion deve ter **EXATAMENTE** estas propriedades:
- [ ] **Name** (tipo: Title)
- [ ] **Email** (tipo: Email)
- [ ] **Company** (tipo: Rich Text)
- [ ] **Subject** (tipo: Rich Text)
- [ ] **Message** (tipo: Rich Text)
- [ ] **Created** (tipo: Date)
- [ ] **Status** (tipo: Select com opções: new, responded, archived)

### 4️⃣ **Integração Não Compartilhada**
- [ ] A Integration `linear-hub-contact-form` foi convidada para a database?
- [ ] Ela tem permissão de **Edit**?

## Como Verificar os Logs:

### AWS CloudWatch:
1. Vá para: AWS → CloudWatch → Log Groups
2. Procure por: `/aws/lambda/linear-hub-contact-api`
3. Abra o log mais recente
4. Procure por: `=== NOTION INTEGRATION CHECK ===`
5. Veja as mensagens de erro

### Mensagens de Erro Comuns:

**❌ "NOTION_API_KEY exists: false"**
→ Secret não foi sincronizado

**❌ "NOTION_CONTACTS_DATABASE_ID exists: false"**
→ Secret não foi sincronizado

**❌ Status: 401 Unauthorized**
→ API Key inválida ou expirada

**❌ Status: 404 database not found**
→ Database ID está incorreto

**❌ Status: 400 Invalid request body**
→ Propriedades da database não correspondem

## Próximos Passos:

1. **Veja os logs do CloudWatch** (instruções acima)
2. **Identifique qual erro você vê**
3. **Reporte o erro específico**
