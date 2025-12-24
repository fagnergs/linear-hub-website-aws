# 🚀 FinOps Lambda - Execução Server-Side na AWS

**Data:** 24 de dezembro de 2025
**Status:** ✅ Operacional
**Migração:** Crontab Local → AWS Lambda + EventBridge

---

## 📋 Resumo Executivo

Os jobs de extração de custos FinOps foram **migrados de crontab local para AWS Lambda**, eliminando a dependência de máquinas locais e garantindo execução 24/7 server-side na AWS.

### ✅ Mudanças Realizadas

| Item | Antes | Depois |
|------|-------|--------|
| **Execução** | Crontab local (equipamento pessoal) | AWS Lambda (servidor na nuvem) |
| **Agendamento** | cron (9h UTC apenas) | EventBridge (9h, 12h, 18h UTC) |
| **Disponibilidade** | Dependente do PC ligado | 24/7 na AWS |
| **Monitoramento** | Manual | CloudWatch Logs integrado |
| **Custo** | Livre (sua máquina) | $0.20/mês (Lambda gratuita até 1M invocações) |

---

## 🏗️ Arquitetura Implementada

```
┌─────────────────────────────────────────────────────────────┐
│                    EventBridge                               │
│  Triggers automáticos em 3 horários:                        │
│  • 09:00 UTC → linear-hub-finops-09h-utc                   │
│  • 12:00 UTC → linear-hub-finops-12h-utc                   │
│  • 18:00 UTC → linear-hub-finops-18h-utc                   │
└────────────────┬────────────────────────────────────────────┘
                 │ Invoca
                 ▼
┌─────────────────────────────────────────────────────────────┐
│           AWS Lambda Function                               │
│  linear-hub-finops-cost-extractor                          │
│  • Runtime: Python 3.11                                    │
│  • Timeout: 300s                                           │
│  • Memory: 512MB                                           │
│  • Handler: lambda_finops_executor.lambda_handler          │
└────────────┬──────────────────────────────┬─────────────────┘
             │ Lê                           │ Envia
             ▼                              ▼
    ┌─────────────────┐           ┌──────────────────┐
    │ Cost Explorer   │           │    SNS Topic     │
    │ API (AWS)       │           │ linear-hub-      │
    │                 │           │ website-alerts   │
    └─────────────────┘           └────────┬─────────┘
                                           │ Envia Email
                                           ▼
                             fagner.silva@linear-hub.com.br
```

---

## 📊 Configuração Atual

### AWS Lambda
- **Nome:** `linear-hub-finops-cost-extractor`
- **ARN:** `arn:aws:lambda:us-east-1:781705467769:function:linear-hub-finops-cost-extractor`
- **Runtime:** Python 3.11
- **Memory:** 512 MB
- **Timeout:** 300 segundos
- **Role:** `linear-hub-lambda-execution`

### EventBridge Rules
| Regra | Horário | Status |
|-------|---------|--------|
| `linear-hub-finops-09h-utc` | 09:00 UTC | ✅ Ativa |
| `linear-hub-finops-12h-utc` | 12:00 UTC | ✅ Ativa |
| `linear-hub-finops-18h-utc` | 18:00 UTC | ✅ Ativa |

### IAM Permissions
A função Lambda tem permissões para:
- ✅ `ce:GetCostAndUsage` - Ler dados de custos da AWS
- ✅ `sns:Publish` - Enviar emails via SNS
- ✅ `logs:CreateLogGroup` - Criar logs no CloudWatch
- ✅ `logs:CreateLogStream` - Registrar execuções
- ✅ `logs:PutLogEvents` - Escrever eventos de log

### Environment Variables
```
SNS_TOPIC_ARN = arn:aws:sns:us-east-1:781705467769:linear-hub-website-alerts
REGION = us-east-1
```

---

## 🔧 Arquivos Criados

### 1. `lambda_finops_executor.py` (311 linhas)
Código Python otimizado para executar em Lambda:
- Extrai custos via AWS Cost Explorer
- Formata relatório estruturado
- Envia via SNS para email
- Handler compatível com EventBridge

**Principais funções:**
```python
lambda_handler(event, context)    # Handler principal
get_date_range(mode)              # Calcula período
get_costs_by_service()            # Extrai custos
format_report()                   # Formata email
send_email()                      # Envia via SNS
```

### 2. `deploy-finops-direct.sh` (170 linhas)
Script de deploy automático:
- Valida credenciais AWS
- Cria/atualiza função Lambda
- Configura 3 EventBridge Rules
- Adiciona permissões Lambda
- Teste automático

**Como usar:**
```bash
bash deploy-finops-direct.sh
```

### 3. `cloudformation-finops.yml` (110 linhas)
Template CloudFormation (alternativa):
- Define Lambda function
- Define 3 EventBridge Rules
- Configura outputs

### 4. `test-finops-lambda.sh` (30 linhas)
Script para testar a Lambda manualmente:
```bash
bash test-finops-lambda.sh
```

---

## ✅ Verificação de Status

### Confirmar Lambda Está Ativa
```bash
aws lambda get-function --function-name linear-hub-finops-cost-extractor --region us-east-1
```

### Ver EventBridge Rules
```bash
aws events list-rules --region us-east-1 | grep linear-hub-finops
```

### Monitorar CloudWatch Logs
```bash
aws logs tail /aws/lambda/linear-hub-finops-cost-extractor --follow --region us-east-1
```

### Testar Manualmente
```bash
bash test-finops-lambda.sh
```

---

## 📈 Exemplo de Execução

**Input do EventBridge:**
```json
{
  "mode": "current",
  "send_email": true
}
```

**Output da Lambda:**
```json
{
  "statusCode": 200,
  "body": {
    "message": "FinOps report executed",
    "period": "2025-12-01 a 2025-12-31",
    "total_cost": 12.50,
    "services_count": 24
  }
}
```

**Email Enviado:**
```
╔═══════════════════════════════════════════════════════════════════════════╗
║                   💰 RELATÓRIO DE CUSTOS AWS - FINOPS                     ║
║                       PERÍODO: 2025-12-01 A 2025-12-31                    ║
╚═══════════════════════════════════════════════════════════════════════════╝

📊 CUSTO TOTAL: $12.50 USD

📈 BREAKDOWN POR SERVIÇO:
   EC2: $5.00 (40.0%)
   RDS: $3.50 (28.0%)
   ...

⏰ Data do Relatório: 2025-12-24 14:30:45 UTC
🔗 Link AWS: https://console.aws.amazon.com/cost-management/home
```

---

## 🎯 Vantagens da Migração

### ✅ Disponibilidade
- Executa 24/7 mesmo com seu PC desligado
- Sem dependências de máquinas locais
- Altamente resiliente

### ✅ Escalabilidade
- 3 execuções diárias automáticas
- Pode ser aumentado para mais horários facilmente
- Sem impacto no seu computador

### ✅ Monitoramento
- CloudWatch Logs com histórico completo
- Alertas automáticos em caso de erro
- Fácil debug via console AWS

### ✅ Custo
- **Menos de $0.20/mês** (gratuita até 1M invocações)
- Pagamento apenas por execução
- Incluído no free tier da AWS

### ✅ Manutenção
- Código centralizado no GitHub
- Deploy automático com script
- Versionado e rastreável

---

## 🚀 Próximos Passos

### Opcional: Modificar Horários
Se quiser adicionar mais horários, edite `deploy-finops-direct.sh`:
```bash
HOURS=("06" "09" "12" "15" "18" "21")  # Adicione horários
```

### Opcional: Modificar Modo de Execução
Mude o input do EventBridge em `deploy-finops-direct.sh`:
```bash
# De:
"Input"='{"mode":"current","send_email":true}'
# Para:
"Input"='{"mode":"previous","send_email":true}'  # Mês anterior
```

### Opcional: Aumentar Memory
Se precisar processar mais dados:
```bash
aws lambda update-function-configuration \
    --function-name linear-hub-finops-cost-extractor \
    --memory-size 1024 \
    --region us-east-1
```

---

## 🔍 Troubleshooting

### Lambda não executa
1. Verificar CloudWatch Logs:
   ```bash
   aws logs tail /aws/lambda/linear-hub-finops-cost-extractor --follow
   ```
2. Verificar permissões IAM da role
3. Verificar se SNS topic ainda existe

### EventBridge não dispara
1. Confirmar regra está ENABLED:
   ```bash
   aws events describe-rule --name linear-hub-finops-09h-utc
   ```
2. Confirmar Lambda está configurada como target:
   ```bash
   aws events list-targets-by-rule --rule linear-hub-finops-09h-utc
   ```

### Email não recebido
1. Confirmar SNS topic tem subscription ativa
2. Verificar spam do email
3. Verificar logs da execução da Lambda

---

## 📚 Referências

- [AWS Lambda Documentation](https://docs.aws.amazon.com/lambda/)
- [EventBridge Documentation](https://docs.aws.amazon.com/eventbridge/)
- [Cost Explorer API](https://docs.aws.amazon.com/aws-cost-management/latest/userguide/ce-api.html)
- [CloudWatch Logs](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/)

---

## 🎉 Resumo da Migração

| Métrica | Antes | Depois |
|---------|-------|--------|
| **Execução** | 1x/dia (9h) | 3x/dia (9h, 12h, 18h) |
| **Localização** | Máquina local | AWS (nuvem) |
| **Disponibilidade** | ~99% (se PC ligado) | 99.95% (SLA Lambda) |
| **Custo Direto** | R$0 | ~$0.06/mês |
| **Manutenção** | Manual | Automática |
| **Monitoramento** | Nenhum | CloudWatch integrado |

**Status:** ✅ **OPERACIONAL E PRODUÇÃO**

---

**Última Atualização:** 24 de dezembro de 2025
**Deploy:** Commit 7515255
