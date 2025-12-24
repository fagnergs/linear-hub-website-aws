# 🔄 GitHub Actions - Workflows de Sincronização

## 📋 Workflows Disponíveis

### 1. **sync-main-to-develop** (NOVO - AUTOMÁTICO)
```yaml
Triggers:
  - Push em main (automático)
  - workflow_dispatch (manual via GitHub UI)

Função:
  - Sincroniza automaticamente main → develop
  - Cria branch develop se não existir
  - Detecta conflitos de merge
  - Gera relatório de sucesso

Status: ✅ Ativo
```

### 2. **sync-secrets-to-lambda** (REMOVIDO - 24/12/2025) ❌
```yaml
Triggers:
  - Daily cron: 2:00 AM UTC (REMOVIDO)
  - workflow_dispatch (REMOVIDO)

Status: ❌ REMOVIDO - Desnecessário
Razão: 
  - Site usa Next.js API Route (/api/contact.ts)
  - Lambda não é utilizado para processamento de contatos
  - Secrets já configuradas no next.config.js/.env
  - Removido para eliminar erro de saída (exit code 3)
```

### 3. **deploy** (Existente)
```yaml
Triggers:
  - Push em main
  - Pull requests em main

Função:
  - Build do projeto Node.js
  - Lint de código
  - Testes básicos

Status: ✅ Ativo
```

### 4. **deploy-aws** (Existente)
```yaml
Triggers:
  - Manual via workflow_dispatch

Função:
  - Deploy em produção para AWS
  - Atualiza recursos em produção

Status: ✅ Ativo
```

---

## 🔧 Análise: sync-secrets-to-lambda REMOVIDO

### Problema Original
**Workflow:** sync-secrets-to-lambda  
**Erro:** Exit code 3  
**Causa:** Teste Slack aguardava string "ok", mas curl retorna HTTP status codes

### Decisão: Remover ao invés de Corrigir
**Por que?**
- Lambda `linear-hub-contact-api` não é utilizado pelo site
- Site usa Next.js API Route (`/api/contact.ts`) para formulário de contato
- Secrets já estão configurados no `.env` (não precisam sincronizar com Lambda)
- Remover o workflow elimina o erro SEM impacto operacional

### Status
✅ **Removido em 24 de dezembro de 2025**  
✅ **Sem impacto no site** (não era usado)

---

## 🔧 Correção Anterior (Documentado para Referência)

Se fosse necessário manter o workflow, a solução seria:
```diff
- RESPONSE=$(curl -s -X POST ...)
- if [ "$RESPONSE" = "ok" ]; then

+ RESPONSE=$(curl -s -w "\n%{http_code}" -X POST ...)
+ HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
+ if [ "$HTTP_CODE" = "200" ]; then
```

---

## ✨ Novo Workflow: Sincronização Automática

### O que faz?
Sincroniza automaticamente mudanças de `main` para `develop` toda vez que você faz push em main.

### Como funciona?
```
Push em main
    ↓
GitHub Actions dispara
    ↓
Checkout repository
    ↓
Merge main → develop
    ↓
Push em develop
    ↓
✅ Pronto!
```

### Como usar?

**Automático (recomendado):**
```bash
# Fazer push em main normalmente
git push origin main

# O workflow executa automaticamente
# Sincroniza com develop automaticamente
```

**Manual (se necessário):**
```
GitHub → Actions → Sync main to develop → Run workflow
```

---

## 🚀 Executar Workflows Manualmente

### Via GitHub CLI
```bash
# Sincronizar main → develop
gh workflow run sync-main-to-develop.yml -r main

# Sincronizar secrets para Lambda
gh workflow run sync-secrets-to-lambda.yml -r main

# Build & Test
gh workflow run deploy.yml -r main
```

### Via GitHub UI
```
Repository → Actions → [Workflow Name] → Run workflow
```

---

## 📊 Status dos Workflows

| Workflow | Status | Última Execução | Próxima |
|----------|--------|-----------------|---------|
| sync-main-to-develop | ✅ OK | Após último push | Automático |
| sync-secrets-to-lambda | ✅ FIXED | 02:00 UTC | Próximas 24h |
| deploy | ✅ OK | Último push main | Próximo push |
| deploy-aws | ✅ OK | Manual | Manual |

---

## 🔍 Verificar Logs

### GitHub UI
```
Repository → Actions → [Workflow] → Latest run → Details
```

### GitHub CLI
```bash
# Ver últimas execuções
gh run list --workflow=sync-secrets-to-lambda.yml

# Ver detalhes de uma execução
gh run view <run_id>

# Ver logs de um job
gh run view <run_id> --log
```

---

## ⚙️ Configurações Importantes

### Secrets Necessários
```
AWS_ACCESS_KEY_ID ...................... ✅ Configurado
AWS_SECRET_ACCESS_KEY .................. ✅ Configurado
AWS_REGION ............................ ✅ Configurado
SLACK_WEBHOOK_URL ..................... ⚠️  Opcional
```

### Branches
```
main ........ Produção, commits protegidos
develop .... Desenvolvimento, sincronizado automaticamente
```

---

## 🐛 Troubleshooting

### Sync não funciona?
```bash
# Verificar status
gh run list --workflow=sync-main-to-develop.yml

# Ver detalhes do erro
gh run view <run_id> --log

# Sincronizar manualmente
git checkout develop
git merge main
git push origin develop
```

### Secrets não sincronizam?
```bash
# Verificar se workflow tem permissão
# Repository Settings → Actions → General → Workflow permissions

# Deve ter: Read and write permissions
```

### Slack não notifica?
```bash
# 1. Verificar se webhook está configurado
Repository Settings → Secrets and variables → Actions

# 2. Verificar se webhook URL é válida
curl -X POST -H 'Content-type: application/json' \
  --data '{"text":"Test"}' \
  YOUR_SLACK_WEBHOOK_URL

# 3. Verificar logs do workflow
```

---

## 📈 Próximas Melhorias

- [ ] Adicionar Discord notifications (alternativa/adicional ao Slack)
- [ ] Criar workflow para validação de branches
- [ ] Adicionar auto-rebase de develop em main
- [ ] Criar workflow para release management
- [ ] Adicionar status badges no README

---

## 📞 Referência Rápida

**Atualizar secrets:**
```
Settings → Secrets and variables → Actions → New repository secret
```

**Reexecução de um workflow:**
```
Actions → [Workflow] → [Failed run] → Re-run failed jobs
```

**Sincronização manual:**
```bash
git checkout develop && git pull origin main && git push
```

**Ver próxima execução agendada:**
```bash
# No arquivo do workflow (.github/workflows/sync-secrets-to-lambda.yml)
# cron: '0 2 * * *' = Diariamente às 02:00 UTC
```

---

**Última atualização:** 23 de dezembro de 2025  
**Status:** ✅ Todos os workflows operacionais
**Erro corrigido:** sync-secrets-to-lambda exit code 3
