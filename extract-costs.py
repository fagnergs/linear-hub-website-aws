#!/usr/bin/env python3
"""
AWS Cost Extractor - Automação Contínua de Custos FinOps
======================================================

Extrai custos reais da AWS e envia relatórios via SNS.
Pode ser executado via cron/agendador para atualizações automáticas.

Uso:
    python3 extract-costs.py                    # Custos do mês anterior
    python3 extract-costs.py --current          # Custos do mês atual
    python3 extract-costs.py --date 2025-12-01 # Período customizado
    python3 extract-costs.py --send-email       # Enviar via SNS
"""

import boto3
import json
import argparse
import sys
from datetime import datetime, timedelta
from typing import Dict, List, Tuple

# Configuração
SNS_TOPIC_ARN = "arn:aws:sns:us-east-1:781705467769:linear-hub-website-alerts"
AWS_REGION = "us-east-1"
EMAIL_RECIPIENT = "fagner.silva@linear-hub.com.br"


class CostExtractor:
    """Extrator de custos AWS com análise detalhada."""

    def __init__(self, region: str = AWS_REGION):
        self.ce = boto3.client('ce', region_name=region)
        self.sns = boto3.client('sns', region_name=region)
        self.region = region

    def get_date_range(self, mode: str = "previous") -> Tuple[str, str]:
        """Calcula intervalo de datas.
        
        Args:
            mode: 'previous' (mês anterior), 'current' (mês atual), 'today' (dia atual)
            
        Returns:
            Tupla (start_date, end_date) em formato YYYY-MM-DD
        """
        today = datetime.utcnow().date()

        if mode == "current":
            # Mês atual
            start = today.replace(day=1)
            # Próximo dia do próximo mês (exclusive)
            if today.month == 12:
                end = today.replace(year=today.year + 1, month=1, day=1)
            else:
                end = today.replace(month=today.month + 1, day=1)

        elif mode == "today":
            # Dia atual
            start = today
            end = today + timedelta(days=1)

        else:  # previous
            # Mês anterior
            first_day = today.replace(day=1)
            last_day_prev = first_day - timedelta(days=1)
            start = last_day_prev.replace(day=1)
            end = first_day

        return str(start), str(end)

    def get_costs_by_service(
        self,
        start_date: str,
        end_date: str,
        group_by: str = "SERVICE"
    ) -> Dict[str, float]:
        """Extrai custos agrupados por serviço.
        
        Args:
            start_date: Data inicial (YYYY-MM-DD)
            end_date: Data final (YYYY-MM-DD)
            group_by: 'SERVICE', 'LINKED_ACCOUNT', etc
            
        Returns:
            Dicionário {serviço: custo}
        """
        try:
            response = self.ce.get_cost_and_usage(
                TimePeriod={
                    'Start': start_date,
                    'End': end_date
                },
                Granularity='MONTHLY',
                Metrics=['UnblendedCost'],
                GroupBy=[{'Type': 'DIMENSION', 'Key': group_by}]
            )

            costs = {}
            total = 0

            for result in response['ResultsByTime']:
                for group in result.get('Groups', []):
                    service = group['Keys'][0]
                    cost = float(group['Metrics']['UnblendedCost']['Amount'])
                    if cost > 0.001:  # Ignorar custos muito pequenos
                        costs[service] = cost
                        total += cost

            return costs

        except Exception as e:
            print(f"❌ Erro ao extrair custos: {str(e)}")
            return {}

    def get_total_cost(
        self,
        start_date: str,
        end_date: str
    ) -> float:
        """Obtém custo total do período."""
        try:
            response = self.ce.get_cost_and_usage(
                TimePeriod={'Start': start_date, 'End': end_date},
                Granularity='MONTHLY',
                Metrics=['UnblendedCost']
            )

            if response['ResultsByTime']:
                return float(
                    response['ResultsByTime'][0]['Total']['UnblendedCost']['Amount']
                )
            return 0.0

        except Exception as e:
            print(f"❌ Erro ao obter custo total: {str(e)}")
            return 0.0

    def format_report(
        self,
        costs: Dict[str, float],
        start_date: str,
        end_date: str,
        title: str = "Relatório de Custos"
    ) -> str:
        """Formata relatório em texto limpo."""
        total = sum(costs.values())
        
        # Cabeçalho
        report = f"""
{title.upper()}
{'='*60}

Período: {start_date} até {end_date}
Data da Consulta: {datetime.utcnow().strftime('%d/%m/%Y %H:%M:%S UTC')}

RESUMO:
{'-'*60}
Total do Período: ${total:.2f} USD

DETALHAMENTO POR SERVIÇO:
{'-'*60}
"""

        # Serviços ordenados por custo (decrescente)
        sorted_costs = sorted(costs.items(), key=lambda x: x[1], reverse=True)
        
        for service, cost in sorted_costs:
            percentage = (cost / total * 100) if total > 0 else 0
            report += f"{service:.<40} ${cost:>8.2f} ({percentage:>5.1f}%)\n"

        report += f"{'-'*60}\n"
        report += f"{'TOTAL':.<40} ${total:>8.2f} (100.0%)\n"
        report += f"{'='*60}\n\n"

        return report, total

    def send_email(self, subject: str, message: str) -> str:
        """Envia relatório via SNS.
        
        Returns:
            MessageId da publicação SNS
        """
        try:
            response = self.sns.publish(
                TopicArn=SNS_TOPIC_ARN,
                Subject=subject,
                Message=message
            )
            return response['MessageId']

        except Exception as e:
            print(f"❌ Erro ao enviar email: {str(e)}")
            return None

    def analyze_costs(
        self,
        current_costs: Dict[str, float],
        previous_costs: Dict[str, float] = None
    ) -> str:
        """Gera análise de custos com tendências.
        
        Returns:
            Texto de análise
        """
        current_total = sum(current_costs.values())
        
        analysis = "\n📊 ANÁLISE:\n"
        analysis += "-" * 60 + "\n"

        # Top 3 serviços
        sorted_costs = sorted(
            current_costs.items(),
            key=lambda x: x[1],
            reverse=True
        )[:3]

        analysis += "Top 3 Serviços Mais Caros:\n"
        for i, (service, cost) in enumerate(sorted_costs, 1):
            pct = (cost / current_total * 100) if current_total > 0 else 0
            analysis += f"  {i}. {service:.<35} ${cost:>8.2f} ({pct:.1f}%)\n"

        # Comparação com período anterior
        if previous_costs:
            previous_total = sum(previous_costs.values())
            diff = current_total - previous_total
            pct_change = (diff / previous_total * 100) if previous_total > 0 else 0

            analysis += f"\nComparação com Período Anterior:\n"
            analysis += f"  Anterior: ${previous_total:.2f}\n"
            analysis += f"  Atual: ${current_total:.2f}\n"

            if diff > 0:
                analysis += f"  📈 AUMENTO: ${diff:.2f} (+{pct_change:.1f}%)\n"
            elif diff < 0:
                analysis += f"  📉 REDUÇÃO: ${abs(diff):.2f} ({pct_change:.1f}%)\n"
            else:
                analysis += f"  ➡️  ESTÁVEL\n"

        analysis += "-" * 60 + "\n"
        return analysis

    def run(
        self,
        mode: str = "previous",
        send_email: bool = False
    ) -> None:
        """Executa extração completa de custos.
        
        Args:
            mode: 'previous', 'current', 'today'
            send_email: Se True, envia relatório via SNS
        """
        print(f"🔍 Extraindo custos ({mode})...\n")

        start_date, end_date = self.get_date_range(mode)
        
        print(f"Período: {start_date} até {end_date}")
        print(f"Consultando AWS Cost Explorer...\n")

        # Obter custos
        costs = self.get_costs_by_service(start_date, end_date)
        
        if not costs:
            print("⚠️  Sem dados de custos encontrados para este período.")
            return

        # Formatar relatório
        report, total = self.format_report(costs, start_date, end_date)
        print(report)

        # Análise
        if mode == "previous":
            # Obter dois períodos anteriores para comparação
            prev_start, prev_end = self.get_date_range("previous")
            # Voltar mais um mês
            prev_date = datetime.strptime(prev_start, '%Y-%m-%d') - timedelta(days=1)
            older_start = prev_date.replace(day=1).strftime('%Y-%m-%d')
            older_end = prev_start

            previous_costs = self.get_costs_by_service(older_start, older_end)
            
            analysis = self.analyze_costs(costs, previous_costs)
            print(analysis)

            full_report = report + analysis
        else:
            full_report = report

        # Enviar email se solicitado
        if send_email:
            if mode == "previous":
                title = f"Custos AWS - {start_date} a {end_date}"
            elif mode == "current":
                title = f"Custos AWS (Mês Atual) - Até {end_date.split('-')[2]}"
            else:
                title = f"Custos AWS - {start_date}"

            msg_id = self.send_email(
                subject=f"[FinOps] {title}",
                message=full_report
            )

            if msg_id:
                print(f"\n✅ Email enviado com sucesso!")
                print(f"📧 Para: {EMAIL_RECIPIENT}")
                print(f"📬 ID: {msg_id}\n")
            else:
                print(f"\n❌ Erro ao enviar email\n")


def main():
    """Entry point do script."""
    parser = argparse.ArgumentParser(
        description="Extrator automático de custos AWS",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Exemplos:
  python3 extract-costs.py                    # Custos do mês anterior
  python3 extract-costs.py --current          # Custos do mês atual
  python3 extract-costs.py --today            # Custos de hoje
  python3 extract-costs.py --current --send   # Mês atual + enviar email
        """
    )

    parser.add_argument(
        '--current',
        action='store_true',
        help='Mostrar custos do mês atual (ao invés do anterior)'
    )

    parser.add_argument(
        '--today',
        action='store_true',
        help='Mostrar custos de hoje apenas'
    )

    parser.add_argument(
        '--send',
        action='store_true',
        help='Enviar relatório via SNS email'
    )

    parser.add_argument(
        '--json',
        action='store_true',
        help='Saída em formato JSON'
    )

    args = parser.parse_args()

    # Determinar modo
    if args.today:
        mode = "today"
    elif args.current:
        mode = "current"
    else:
        mode = "previous"

    # Executar
    extractor = CostExtractor()
    
    try:
        extractor.run(mode=mode, send_email=args.send)
    except KeyboardInterrupt:
        print("\n\n⚠️  Operação cancelada pelo usuário.")
        sys.exit(0)
    except Exception as e:
        print(f"\n❌ Erro: {str(e)}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
