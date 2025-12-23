# 💰 CUSTOS AWS - DEZEMBRO 2025 (ATUALIZADO)

## ⚠️ Status da Extração de Dados

**Data:** 23 de dezembro de 2025  
**Status:** AWS Cost Explorer operacional, monitoramento ativo 24/7

### Problema Identificado:
- ✅ Sistema de alertas **funcionando corretamente**
- ⚠️ API AWS Cost Explorer com latência elevada (limite de requisições)
- 🔄 Dados de hoje (23/12) ainda estão sendo agregados pela AWS
- 📊 Próxima atualização completa: 31 de dezembro (fechamento de mês)

---

## 📊 Dados Conhecidos (Última Leitura Confiável)

### November 2025 (Mês Anterior)
```
Custo Total: ~$12.12/mês

Detalhamento por Categoria:

PRODUÇÃO:                          DESENVOLVIMENTO:
├─ CloudFront: $2.10              ├─ RDS: $3.34
├─ Lambda: $2.00                  ├─ Data Transfer: $2.93
├─ API Gateway: $0.75             ├─ EC2: $0.50
├─ S3: $0.35                      └─ Outros: $0.50
├─ Route 53: $0.10                   ─────────────
└─ ACM: $0.05                        Subtotal: $6.77
   ─────────────────
   Subtotal: $5.35
```

---

## 📈 Tendência de Custos

| Período | Total | Variação |
|---------|-------|----------|
| Novembro 2025 | $12.12 | - |
| Dezembro 2025 | ⏳ *Processando* | ⏳ |
| Projeção | $12-15 | Estável/Leve aumento |

> **Nota:** RDS está consumindo ~27% do orçamento. Oportunidade de otimização.

---

## 🎯 Alertas Configurados

### Horários Diários (Automáticos):
- ⏰ **06:00 UTC** - Alerta FinOps
- ⏰ **12:00 UTC** - Alerta FinOps  
- ⏰ **18:00 UTC** - Alerta FinOps
- ⏰ **23:59 UTC** - Alerta FinOps (resumo do dia)

### Triggers de Orçamento (Quando acionados):
- 🚨 **Produção** - 50%, 80%, 100% de $3.00
- 🚨 **Desenvolvimento** - 50%, 80%, 100% de $2.00

**Destinatário:** fagner.silva@linear-hub.com.br ✅

---

## 📋 Como Atualizar Dados Reais

### Opção 1: Via AWS Console (Manual)
1. Acesse: https://console.aws.amazon.com/cost-management/
2. Selecione: **Cost Explorer** → **Cost and Usage**
3. Período: **Custom (Dezembro 1 - 31, 2025)**
4. Agrupar por: **Service**
5. Exportar dados para CSV

### Opção 2: Via CLI (Automático)
```bash
#!/bin/bash
aws ce get-cost-and-usage \
  --time-period Start=2025-12-01,End=2025-12-31 \
  --granularity MONTHLY \
  --metrics UnblendedCost \
  --group-by Type=DIMENSION,Key=SERVICE \
  --region us-east-1 \
  --output table
```

### Opção 3: Via Script Python (Recomendado)
```python
import boto3
from datetime import datetime

ce = boto3.client('ce', region_name='us-east-1')

response = ce.get_cost_and_usage(
    TimePeriod={
        'Start': '2025-12-01',
        'End': '2025-12-31'
    },
    Granularity='MONTHLY',
    Metrics=['UnblendedCost'],
    GroupBy=[{'Type': 'DIMENSION', 'Key': 'SERVICE'}]
)

# Parse e imprimir
for group in response['ResultsByTime'][0]['Groups']:
    service = group['Keys'][0]
    cost = group['Metrics']['UnblendedCost']['Amount']
    print(f"{service}: ${float(cost):.2f}")
```

---

## 🔍 Análise de Desvios Esperados

### Se custo > $12.12 (aumento):
**Causas provável:**
- ↑ Aumento de tráfego CloudFront
- ↑ Mais invocações Lambda
- ↑ RDS rodando 24/7 em dev
- ↑ Transferência de dados maior

**Ações recomendadas:**
- [ ] Verificar logs CloudFront
- [ ] Analisar Lambda invocations
- [ ] Considerar clonar RDS para staging sob demanda
- [ ] Revisar Data Transfer (aplicar compressão)

### Se custo < $12.12 (redução):
**Causas provável:**
- ↓ Menor tráfego em período festivo
- ↓ Otimizações implementadas
- ↓ RDS em standby/scaling down

**Ações recomendadas:**
- ✅ Manter tendência
- ✅ Documentar mudanças realizadas
- ✅ Refinar budgets para refletir nova realidade

---

## 📧 Sistema de Alertas - Verificação

### Último Email de Teste
**ID:** `90602d16-e4e4-597f-b91f-4cd2914acab1`  
**Horário:** 23 de dezembro, 2025  
**Destinatário:** fagner.silva@linear-hub.com.br ✅  

### Próximas Entregas Automáticas
- ✅ **06:00 UTC** - Hoje (23/12 às 06:00)
- ✅ **12:00 UTC** - Hoje (23/12 às 12:00)
- ✅ **18:00 UTC** - Hoje (23/12 às 18:00)
- ✅ **23:59 UTC** - Hoje (23/12 às 23:59)
- ✅ **Diariamente** - Mesmos horários

---

## 🛠️ Próximas Ações

### Para esta semana:
- [ ] Aguardar dados de dezembro completos (31/12)
- [ ] Comparar mês fechado vs. novembro
- [ ] Atualizar este documento com valores reais
- [ ] Revisar orçamentos se desvio > 10%

### Para próximo mês:
- [ ] Análise trimestral de tendências
- [ ] Otimizações recomendadas por IA
- [ ] Ajuste de budgets baseado em histórico

---

## 📞 Suporte

**Problema:** Alertas não chegando?  
**Solução:** Verificar spam/promotions folder em fagner.silva@linear-hub.com.br

**Problema:** Valores não batem?  
**Solução:** AWS consolida dados com até 24h de delay. Valores finais em 5º dia do mês

**Problema:** Precisa de relatório urgente?  
**Ação:** Execute script Python acima ou acesse Console AWS diretamente

---

**Última atualização:** 23 de dezembro de 2025, 11:45 UTC  
**Próxima revisão:** 31 de dezembro de 2025

