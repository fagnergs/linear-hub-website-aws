#!/usr/bin/env python3
"""
AWS Lambda FinOps Cost Extractor
=================================
Versão otimizada do extract-costs.py para executar em AWS Lambda.
Integrada com EventBridge para execução horária.

Environment Variables esperadas:
- SNS_TOPIC_ARN: ARN do tópico SNS
- AWS_REGION: Região AWS (default: us-east-1)
"""

import boto3
import json
import os
from datetime import datetime, timedelta
from typing import Dict, List, Tuple

# Configuração
SNS_TOPIC_ARN = os.getenv('SNS_TOPIC_ARN', 'arn:aws:sns:us-east-1:781705467769:linear-hub-website-alerts')
AWS_REGION = os.getenv('REGION', 'us-east-1')
EMAIL_RECIPIENT = 'fagner.silva@linear-hub.com.br'


class CostExtractor:
    """Extrator de custos AWS com análise detalhada."""

    def __init__(self, region: str = AWS_REGION):
        self.ce = boto3.client('ce', region_name=region)
        self.sns = boto3.client('sns', region_name=region)
        self.region = region

    def get_date_range(self, mode: str = "current") -> Tuple[str, str]:
        """Calcula intervalo de datas.
        
        Args:
            mode: 'previous' (mês anterior), 'current' (mês atual)
            
        Returns:
            Tupla (start_date, end_date) em formato YYYY-MM-DD
        """
        today = datetime.utcnow().date()

        if mode == "current":
            # Mês atual
            start = today.replace(day=1)
            next_month = start + timedelta(days=32)
            end = next_month.replace(day=1) - timedelta(days=1)
        else:
            # Mês anterior (padrão)
            first_today = today.replace(day=1)
            last_day_previous = first_today - timedelta(days=1)
            start = last_day_previous.replace(day=1)
            end = last_day_previous

        return str(start), str(end)

    def get_costs_by_service(self, start_date: str, end_date: str) -> Dict[str, float]:
        """Extrai custos por serviço do Cost Explorer."""
        try:
            response = self.ce.get_cost_and_usage(
                TimePeriod={
                    'Start': start_date,
                    'End': end_date
                },
                Granularity='MONTHLY',
                Metrics=['UnblendedCost'],
                GroupBy=[
                    {
                        'Type': 'DIMENSION',
                        'Key': 'SERVICE'
                    }
                ]
            )

            costs = {}
            for result in response['ResultsByTime']:
                for group in result['Groups']:
                    service = group['Keys'][0]
                    cost = float(group['Metrics']['UnblendedCost']['Amount'])
                    costs[service] = cost

            return costs
        except Exception as e:
            print(f"❌ Erro ao extrair custos: {str(e)}")
            raise

    def calculate_total_cost(self, costs: Dict[str, float]) -> float:
        """Calcula custo total."""
        return sum(costs.values())

    def format_report(self, costs: Dict[str, float], period: str) -> str:
        """Formata relatório de custos para envio via email."""
        total = self.calculate_total_cost(costs)
        
        # Ordenar por custo (maior primeiro)
        sorted_costs = sorted(costs.items(), key=lambda x: x[1], reverse=True)

        report = f"""
╔═══════════════════════════════════════════════════════════════════════════╗
║                   💰 RELATÓRIO DE CUSTOS AWS - FINOPS                     ║
║                          {period.upper()}                                  ║
╚═══════════════════════════════════════════════════════════════════════════╝

📊 CUSTO TOTAL: ${total:,.2f} USD

📈 BREAKDOWN POR SERVIÇO:
"""

        for service, cost in sorted_costs:
            percentage = (cost / total * 100) if total > 0 else 0
            report += f"   {service}: ${cost:,.2f} ({percentage:.1f}%)\n"

        report += f"""
⏰ Data do Relatório: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')} UTC
🔗 Link AWS: https://console.aws.amazon.com/cost-management/home?region=us-east-1

"""
        return report

    def send_email(self, report: str, subject: str = "📊 Relatório de Custos AWS - FinOps") -> bool:
        """Envia relatório via SNS para email."""
        try:
            response = self.sns.publish(
                TopicArn=SNS_TOPIC_ARN,
                Message=report,
                Subject=subject
            )
            print(f"✅ Email enviado com sucesso! MessageId: {response['MessageId']}")
            return True
        except Exception as e:
            print(f"❌ Erro ao enviar email: {str(e)}")
            return False

    def extract_and_report(self, mode: str = "current", send_email: bool = True) -> Dict:
        """Executa extração completa de custos e envia relatório."""
        try:
            start_date, end_date = self.get_date_range(mode)
            costs = self.get_costs_by_service(start_date, end_date)
            total = self.calculate_total_cost(costs)
            report = self.format_report(costs, f"Período: {start_date} a {end_date}")

            if send_email:
                self.send_email(report)

            return {
                'statusCode': 200,
                'period': f"{start_date} a {end_date}",
                'total_cost': total,
                'services': costs,
                'report': report
            }
        except Exception as e:
            print(f"❌ Erro na extração: {str(e)}")
            return {
                'statusCode': 500,
                'error': str(e)
            }


def lambda_handler(event, context):
    """
    Handler da Lambda para EventBridge.
    
    Event pode conter:
    - 'mode': 'current' ou 'previous' (default: 'current')
    - 'send_email': True ou False (default: True)
    """
    
    mode = event.get('mode', 'current')
    send_email = event.get('send_email', True)
    
    print(f"🚀 FinOps Lambda iniciada - Mode: {mode}, SendEmail: {send_email}")
    
    extractor = CostExtractor()
    result = extractor.extract_and_report(mode=mode, send_email=send_email)
    
    return {
        'statusCode': result.get('statusCode', 200),
        'body': json.dumps({
            'message': 'FinOps report executed',
            'period': result.get('period'),
            'total_cost': result.get('total_cost'),
            'services_count': len(result.get('services', {}))
        })
    }


# Para testes locais
if __name__ == "__main__":
    event = {'mode': 'current', 'send_email': True}
    result = lambda_handler(event, None)
    print(json.dumps(result, indent=2))
