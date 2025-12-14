# Integrations Guide - Linear Hub Website

## Overview

Este projeto integra três plataformas externas para fluxos de trabalho automatizados:

- **Slack**: Notificações de contatos novos e status de deployments
- **Notion**: Logging persistente de contatos e deployments em bancos de dados
- **Linear**: Criação automática de tarefas para contatos e issues para falhas de deploy

---

## Setup Instructions

### 1. Slack Integration ✅

#### Configuração Slack

1. Acesse seu workspace Slack
2. Vá para: **Settings → Integrations → Apps** (ou procure por "Apps" na barra lateral)
3. Clique em **"Create New App"** → **"From scratch"**
4. Nome: `Linear Hub Website`
5. Selecione seu workspace

#### Criar Webhook

1. Na página do app, vá para **"Incoming Webhooks"** no menu lateral
2. Clique em **"Add New Webhook to Workspace"**
3. Selecione o channel `#general` (ou crie `#contacts` e `#deployments`)
4. Copie a **Webhook URL** (será assim: `https://hooks.slack.com/services/YOUR/WEBHOOK/URL`)

#### Adicionar ao GitHub Secrets

```bash
# Terminal ou GitHub CLI
gh secret set SLACK_WEBHOOK_URL --body "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
```

Ou via UI: **Settings → Secrets and variables → Actions → New repository secret**

---

### 2. Notion Integration ✅

#### Criar Bancos de Dados

**Database 1: Contatos**

1. Abra notion.so
2. Crie um novo database com o nome `Contatos`
3. Adicione as seguintes propriedades (colunas):
   - `Name` (Title) - Nome do contato
   - `Email` (Email) - Email do contato
   - `Company` (Rich Text) - Empresa
   - `Subject` (Rich Text) - Assunto do contato
   - `Message` (Rich Text) - Mensagem completa
   - `Created` (Date) - Data de recebimento
   - `Status` (Select) - Opções: `new`, `in-progress`, `resolved`

**Database 2: Deployments**

1. Crie outro database com o nome `Deployments`
2. Adicione as seguintes propriedades:
   - `Branch` (Title) - Nome da branch (main, develop, etc)
   - `Commit` (Rich Text) - Hash do commit
   - `Status` (Select) - Opções: `success`, `failure`
   - `Timestamp` (Date) - Quando foi o deploy
   - `Duration` (Number) - Duração em segundos

#### Gerar Notion API Key

1. Acesse: https://www.notion.so/my-integrations
2. Clique em **"Create new integration"**
3. Nome: `Linear Hub GitHub CI`
4. Desmarque tudo exceto `Read` e `Update` (Content capabilities)
5. Copie o **Internal Integration Token** (começa com `ntion_`)

#### Adicionar Notion ao GitHub Secrets

```bash
gh secret set NOTION_API_KEY --body "ntion_your_api_key_here"
gh secret set NOTION_CONTACTS_DATABASE_ID --body "your_database_id_here"
gh secret set NOTION_DEPLOYMENTS_DATABASE_ID --body "your_database_id_here"
```

**Como encontrar Database IDs?**

- Abra o database no Notion
- A URL será: `https://www.notion.so/your-workspace/DATABASE_ID?v=...`
- Copie a parte entre `/` e `?`

---

### 3. Linear Integration ✅

#### Criar Linear API Key

1. Acesse seu workspace Linear
2. Vá para **Settings → API** (ou **Settings → Developer**)
3. Clique em **"Create new API key"**
4. Copie a chave

#### Adicionar ao GitHub Secrets

```bash
gh secret set LINEAR_API_KEY --body "lin_your_api_key_here"
```

**Nota:** O código usa `teamId: "team-1"` por padrão. Se sua equipe tiver ID diferente, avise para ajustar.

---

## Usage in Code

### Lambda Function (aws/lambda/index.js)

Quando um contato é enviado via formulário:

```javascript
// 1. Email é enviado via Resend (sempre crítico)
await sendViaResend(emailData);

// 2. Slack recebe notificação (non-blocking)
await sendSlackNotification(webhookUrl, contactData);

// 3. Notion registra contato (non-blocking)
await addContactToNotion(apiKey, databaseId, contactData);

// 4. Linear cria tarefa (non-blocking)
await createLinearTask(apiKey, subject, message, email);
```

Se qualquer integração falhar, **o email ainda é enviado** (não é bloqueado).

### GitHub Actions Workflow (.github/workflows/deploy-aws.yml)

Quando há push para main:

```yaml
# 1. Build, lint, test
# 2. Deploy para S3
# 3. Invalidar CloudFront
# 4. Deploy Lambda

# 5. Slack notification
#    - Sucesso: ✅ Deploy bem-sucedido
#    - Falha: ❌ Deploy falhou

# 6. (Futuro) Notion logging de deployment
```

---

## Database Function Reference

### Notion: `addContactToNotion(apiKey, databaseId, contact)`

Adiciona entrada ao database de contatos.

**Parâmetros:**
- `apiKey` (string): NOTION_API_KEY
- `databaseId` (string): NOTION_CONTACTS_DATABASE_ID
- `contact` (object):
  - `name`: string
  - `email`: string
  - `company`: string (opcional)
  - `subject`: string
  - `message`: string

**Exemplo:**
```javascript
await addContactToNotion(
  process.env.NOTION_API_KEY,
  process.env.NOTION_CONTACTS_DATABASE_ID,
  {
    name: "João Silva",
    email: "joao@example.com",
    company: "Acme Corp",
    subject: "Preciso de um orçamento",
    message: "Gostaria de um orçamento para serviços de web"
  }
);
```

### Notion: `logDeploymentToNotion(apiKey, databaseId, deployment)`

Adiciona registro de deployment ao database.

**Parâmetros:**
- `apiKey` (string): NOTION_API_KEY
- `databaseId` (string): NOTION_DEPLOYMENTS_DATABASE_ID
- `deployment` (object):
  - `branch`: string
  - `commit`: string
  - `status`: "success" | "failure"
  - `timestamp`: string
  - `duration`: number (opcional, segundos)

**Exemplo:**
```javascript
await logDeploymentToNotion(
  process.env.NOTION_API_KEY,
  process.env.NOTION_DEPLOYMENTS_DATABASE_ID,
  {
    branch: "main",
    commit: "abc123de",
    status: "success",
    timestamp: new Date().toLocaleString('pt-BR'),
    duration: 45
  }
);
```

---

## Troubleshooting

### Slack não está recebendo mensagens

1. ✅ Webhook URL está correta? (começa com `https://hooks.slack.com`)
2. ✅ GitHub Secret `SLACK_WEBHOOK_URL` está setado?
3. ✅ Verificar logs do GitHub Actions em **Actions → Deploy workflow → Logs**

### Notion está vazio

1. ✅ API Key é válida?
2. ✅ Database IDs estão corretos?
3. ✅ Integration tem permissão de **Update** no Notion?
4. ✅ Bancos de dados têm as colunas corretas?

### Linear não cria tarefas

1. ✅ API Key é válida?
2. ✅ `teamId: "team-1"` é o correto? (Você pode verificar em Linear → Settings)
3. ✅ Workspace está ativo?

---

## Environment Variables

Adicione ao `.env.local` para desenvolvimento local:

```bash
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL
NOTION_API_KEY=ntion_your_key
NOTION_CONTACTS_DATABASE_ID=xxxxx
NOTION_DEPLOYMENTS_DATABASE_ID=xxxxx
LINEAR_API_KEY=lin_your_key
```

Para GitHub Actions, use **Settings → Secrets and variables → Actions**.

---

## Monitoring

### Ver quem recebeu notificações

- **Slack**: Canal #contacts, #deployments
- **Notion**: Check the databases directly
- **Linear**: Check the team's issue list

### Debugar integrações

1. Verificar CloudWatch Logs do Lambda
2. Verificar GitHub Actions workflow logs
3. Verificar resposta das APIs em Network tab (DevTools)

---

## Desabilitar Integração

Se quiser desabilitar uma integração:

1. **Slack**: Remover GitHub Secret `SLACK_WEBHOOK_URL` (vazio = skip)
2. **Notion**: Remover `NOTION_API_KEY` ou `NOTION_CONTACTS_DATABASE_ID`
3. **Linear**: Remover `LINEAR_API_KEY`

Integração não configurada = silenciosamente ignorada ✅

---

## Próximos Passos

- [ ] Testar formulário de contato → verificar Slack, Notion, Linear
- [ ] Fazer um push para main → verificar notificação de deploy no Slack
- [ ] Adicionar mais canais Slack se necessário
- [ ] Configurar automações adicionais no Notion (ex: templates, reminders)
- [ ] Integrar Linear issues com GitHub (opcional)

---

## Support

Se encontrar problemas:
1. Verifique os logs do GitHub Actions
2. Valide as credenciais das APIs
3. Certifique-se de que bancos de dados têm as colunas corretas
4. Teste as APIs manualmente com curl/Postman

---

**Last Updated:** Dec 14, 2025
