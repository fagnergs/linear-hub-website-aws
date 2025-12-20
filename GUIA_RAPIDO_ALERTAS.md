# 🚀 GUIA RÁPIDO - Alertas Diários de Custo

## ⚡ Ativar em 1 Minuto

```bash
# Vá para o diretório do projeto
cd /Users/fagnergs/Documents/GitHub/linear-hub-website-aws

# Execute UM destes:
python3 setup-daily-alerts.py    # Recomendado
# OU
bash setup-daily-alerts.sh       # Alternativa
# OU  
bash ACTIVATE_ALERTS.sh          # Comandos manuais
```

**Pronto!** Você terá alertas diários a partir de amanhã às 9:00 AM UTC.

---

## 📊 O Que Você Está Ativando

| Item | Detalhes |
|------|----------|
| **O quê** | Emails de alerta de custo diário |
| **Quando** | 9:00 AM UTC todos os dias |
| **Para quem** | fagner.silva@linear-hub.com.br |
| **Por quê** | Acompanhar custos AWS contra orçamento ($3 produção + $2 dev) |
| **Como** | EventBridge → SNS → Email |

---

## 💡 Fatos Rápidos

- **Custos AWS Reais:** $12.12/mês
  - Produção: $5.35 (CloudFront $2.10, Lambda $2.00)
  - Desenvolvimento: $6.77 (RDS $3.34, Transferência de Dados $2.93)

- **Seus Orçamentos:** $5.00/mês total
  - Produção: $3.00 (atualmente $2.35 acima)
  - Desenvolvimento: $2.00 (atualmente $4.77 acima)

---

## 🧪 Teste

Envie um email de teste:
```bash
aws sns publish \
  --topic-arn arn:aws:sns:us-east-1:781705467769:linear-hub-website-alerts \
  --subject "Teste" \
  --message "Se você vê isto, funciona!" \
  --region us-east-1
```

Deve receber 1 email dentro de 1-2 minutos.

---

## 🔧 Comandos Comuns

### Verificar se está ativo
```bash
aws events describe-rule \
  --name linear-hub-daily-cost-alert-rule \
  --region us-east-1
```
Procure por `"State": "ENABLED"`

### Pausar temporariamente
```bash
aws events disable-rule \
  --name linear-hub-daily-cost-alert-rule \
  --region us-east-1
```

### Retomar
```bash
aws events enable-rule \
  --name linear-hub-daily-cost-alert-rule \
  --region us-east-1
```

### Deletar (se necessário)
```bash
# Remover targets primeiro
aws events remove-targets \
  --rule linear-hub-daily-cost-alert-rule \
  --ids "1" \
  --region us-east-1

# Depois deletar a regra
aws events delete-rule \
  --name linear-hub-daily-cost-alert-rule \
  --region us-east-1
```

### Mudar horário (exemplo: 14:00 em vez de 09:00 UTC)
```bash
aws events put-rule \
  --name linear-hub-daily-cost-alert-rule \
  --schedule-expression "cron(0 14 * * ? *)" \
  --state ENABLED \
  --region us-east-1
```

---

## 📚 Arquivos de Documentação

| Arquivo | Propósito |
|---------|-----------|
| [FINOPS_RESUMO.md](FINOPS_RESUMO.md) | 📖 Comece aqui |
| [FINOPS_ALERTAS_DIARIOS.md](FINOPS_ALERTAS_DIARIOS.md) | 🔍 Configuração detalhada |
| [SETUP_ALERTAS_DIARIOS.md](SETUP_ALERTAS_DIARIOS.md) | 📋 Referência completa |
| [AUDITORIA_FINOPS_2025-12.md](AUDITORIA_FINOPS_2025-12.md) | 💰 Análise de custos |

---

## ❓ FAQ

**P: Quando recebo o primeiro email?**  
R: Amanhã às 9:00 AM UTC (e todos os dias depois)

**P: Posso mudar o horário?**  
R: Sim, veja comando "Mudar horário" acima

**P: E se não receber um email?**  
R: Verifique a pasta de spam, ou verifique as subscrições com:
```bash
aws sns list-subscriptions-by-topic \
  --topic-arn arn:aws:sns:us-east-1:781705467769:linear-hub-website-alerts \
  --region us-east-1
```

**P: Posso adicionar mais destinatários?**  
R: Sim, através do Console AWS SNS

**P: Isto custará dinheiro?**  
R: Não, EventBridge e SNS estão no free tier da AWS para seu uso

---

## 🎯 Próximos Passos

1. ✅ Execute o script de setup (escolha seu método acima)
2. ✅ Envie um email de teste para verificar
3. ✅ Aguarde o alerta automatizado de amanhã
4. ✅ Revise os custos e planeje otimizações
5. ⭐ Considere Fase 2 (relatórios HTML melhorados)

---

## 📞 Precisa de Ajuda?

Verifique os arquivos de documentação ou execute:
```bash
# Teste as credenciais AWS
aws sts get-caller-identity

# Verifique se o tópico SNS existe
aws sns list-topics --region us-east-1

# Veja os detalhes da regra EventBridge
aws events describe-rule \
  --name linear-hub-daily-cost-alert-rule \
  --region us-east-1
```

---

**Status:** ✅ Pronto para Ativar  
**Tempo de Setup:** < 2 minutos  
**Tempo até Primeiro Alerta:** ~24 horas (amanhã @ 9:00 AM UTC)
