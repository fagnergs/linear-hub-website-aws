# 📊 Extrator Automático de Custos AWS

Script Python para extrair, analisar e relatar custos AWS de forma contínua e automatizada.

## 🚀 Início Rápido

### 1. Instalação de Dependências

```bash
pip3 install boto3
```

### 2. Configurar Credenciais AWS

Certifique-se de ter configurado suas credenciais AWS:

```bash
aws configure
# OU defina variáveis de ambiente:
export AWS_ACCESS_KEY_ID=seu_access_key
export AWS_SECRET_ACCESS_KEY=sua_secret_key
```

### 3. Executar Script

```bash
# Básico: Custos do mês anterior
python3 extract-costs.py

# Custos do mês atual
python3 extract-costs.py --current

# Custos de hoje
python3 extract-costs.py --today

# Enviar relatório via email (SNS)
python3 extract-costs.py --current --send

# Enviar custos de hoje
python3 extract-costs.py --today --send
```

## 📋 Exemplos de Uso

### Extrair Custos Mensais

```bash
$ python3 extract-costs.py --current

🔍 Extraindo custos (current)...

Período: 2025-12-01 até 2025-12-24
Consultando AWS Cost Explorer...

RELATÓRIO DE CUSTOS
============================================================

Período: 2025-12-01 até 2025-12-24
Data da Consulta: 23/12/2025 12:30:45 UTC

RESUMO:
────────────────────────────────────────────────────────
Total do Período: $8.45 USD

DETALHAMENTO POR SERVIÇO:
────────────────────────────────────────────────────────
CloudFront.......................... $1.85 (21.9%)
RDS Database Service................ $2.10 (24.9%)
AWS Lambda.......................... $1.50 (17.8%)
EC2 - Other Requests................ $1.20 (14.2%)
API Gateway......................... $0.60 (7.1%)
S3.................................  $0.20 (2.4%)
Data Transfer Out To Internet....... $0.10 (1.2%)
Route 53 DNS Service................ $0.05 (0.6%)
AWS Certificate Manager............. $0.05 (0.6%)
════════════════════════════════════════════════════════

📊 ANÁLISE:
────────────────────────────────────────────────────────
Top 3 Serviços Mais Caros:
  1. RDS Database Service............ $2.10 (24.9%)
  2. CloudFront...................... $1.85 (21.9%)
  3. AWS Lambda...................... $1.50 (17.8%)

Comparação com Período Anterior:
  Anterior: $12.12
  Atual: $8.45
  📉 REDUÇÃO: $3.67 (-30.3%)
────────────────────────────────────────────────────────
```

### Enviar Relatório Automático

```bash
$ python3 extract-costs.py --current --send

✅ Email enviado com sucesso!
📧 Para: fagner.silva@linear-hub.com.br
📬 ID: a1b2c3d4-e5f6-7890-abcd-ef1234567890
```

## ⏰ Automação com Cron

### Setup Automático

```bash
bash setup-cost-scheduler.sh
```

Este comando:
- ✅ Cria diretório de logs
- ✅ Configura permissões de execução
- ✅ Adiciona ao crontab para executar diariamente às 09:00 UTC

### Configuração Manual do Cron

```bash
# Abrir editor de crontab
crontab -e

# Adicionar esta linha (executa diariamente às 09:00 UTC):
0 9 * * * cd /Users/fagnergs/Documents/GitHub/linear-hub-website-aws && python3 extract-costs.py --current --send >> logs/cost-extraction.log 2>&1
```

### Visualizar Agendamentos Ativos

```bash
crontab -l
```

### Visualizar Logs

```bash
# Últimas linhas
tail -20 logs/cost-extraction.log

# Monitorar em tempo real
tail -f logs/cost-extraction.log

# Buscar erros
grep ERROR logs/cost-extraction.log
```

## 📊 Saída esperada

O script gera relatórios estruturados com:

1. **Resumo Total** - Custo total do período
2. **Detalhamento por Serviço** - Custos individuais e percentuais
3. **Análise de Tendências** - Comparação com período anterior
4. **Top Serviços** - 3 maiores consumidores de custo

## 🔧 Configuração Avançada

### Alterar Horário de Execução

Para executar em um horário diferente (ex: 14:00 UTC):

```bash
crontab -e
# Mudar para:
0 14 * * * cd /Users/fagnergs/Documents/GitHub/linear-hub-website-aws && python3 extract-costs.py --current --send >> logs/cost-extraction.log 2>&1
```

### Executar Várias Vezes ao Dia

```bash
# Cada 6 horas
0 0,6,12,18 * * * cd /Users/fagnergs/Documents/GitHub/linear-hub-website-aws && python3 extract-costs.py --current --send >> logs/cost-extraction.log 2>&1

# A cada hora
0 * * * * cd /Users/fagnergs/Documents/GitHub/linear-hub-website-aws && python3 extract-costs.py --current --send >> logs/cost-extraction.log 2>&1
```

### Alterar Destinatário do Email

Edite o arquivo `extract-costs.py`:

```python
# Linha 20 (altere o email):
EMAIL_RECIPIENT = "seu_email@seu_dominio.com.br"
```

## 📈 Interpretando os Relatórios

### Aumento de Custos

Se você vir: `📈 AUMENTO: $2.50 (+20.6%)`

**Causas comuns:**
- Aumento de tráfego CloudFront
- Mais invocações Lambda
- RDS/EC2 rodando mais tempo
- Transferência de dados maior

**Ações recomendadas:**
- [ ] Verificar logs de aplicação
- [ ] Revisar escalabilidade automática
- [ ] Considerar otimizações de cache

### Redução de Custos

Se você vir: `📉 REDUÇÃO: $1.20 (-10.0%)`

**Causas comuns:**
- Menor tráfego (períodos de feriado)
- Otimizações implementadas
- Recursos em standby

**Ações recomendadas:**
- ✅ Manter tendência
- ✅ Documentar mudanças
- ✅ Refinar orçamentos

## 🐛 Troubleshooting

### Erro: "ModuleNotFoundError: No module named 'boto3'"

```bash
pip3 install boto3
```

### Erro: "Unable to locate credentials"

Configure credenciais AWS:
```bash
aws configure
# OU
export AWS_ACCESS_KEY_ID=xxxxx
export AWS_SECRET_ACCESS_KEY=xxxxx
```

### Erro: "NoCredentialsError" ao enviar email

Certifique-se que:
- [ ] As credenciais AWS estão configuradas
- [ ] A conta tem permissão para SNS (arn:aws:sns:...)
- [ ] O tópico SNS existe e está ativo

### Arquivo de Log muito Grande

```bash
# Limpar logs antigos
rm logs/cost-extraction.log

# OU manter apenas últimas 1000 linhas
tail -1000 logs/cost-extraction.log > logs/cost-extraction.log.tmp
mv logs/cost-extraction.log.tmp logs/cost-extraction.log
```

## 📝 Exemplos de Integração

### Lambda Function (AWS)

```python
import subprocess
import os

def lambda_handler(event, context):
    os.chdir('/var/task')  # Diretório do Lambda
    result = subprocess.run(
        ['python3', 'extract-costs.py', '--current', '--send'],
        capture_output=True,
        text=True
    )
    return {
        'statusCode': 200,
        'body': result.stdout
    }
```

### GitHub Actions

```yaml
name: Daily Cost Report
on:
  schedule:
    - cron: '0 9 * * *'  # 9:00 UTC diariamente

jobs:
  cost-report:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-python@v2
        with:
          python-version: '3.9'
      - run: pip install boto3
      - run: python3 extract-costs.py --current --send
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

## 📚 Referências

- [AWS Cost Management API](https://docs.aws.amazon.com/aws-cost-management/latest/APIReference/)
- [Boto3 Documentation](https://boto3.amazonaws.com/v1/documentation/api/latest/index.html)
- [Cron Syntax](https://crontab.guru/)

## 💬 Suporte

**Problema?** Verifique:
1. Logs em `logs/cost-extraction.log`
2. Credenciais AWS com `aws sts get-caller-identity`
3. SNS topic disponível com `aws sns list-topics`

---

**Última atualização:** 23 de dezembro de 2025  
**Versão:** 1.0  
**Status:** ✅ Operacional
