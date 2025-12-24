#!/bin/bash

################################################################################
# Deploy FinOps Lambda + EventBridge - AWS CLI (Direct Approach)
# Expert AWS - Rapid Setup
################################################################################

set -e

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Config
AWS_REGION="us-east-1"
AWS_ACCOUNT_ID="781705467769"
SNS_TOPIC_ARN="arn:aws:sns:us-east-1:781705467769:linear-hub-website-alerts"
LAMBDA_ROLE_NAME="linear-hub-lambda-execution"
LAMBDA_FUNCTION_NAME="linear-hub-finops-cost-extractor"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      Deploy FinOps Lambda - Direct AWS CLI (Expert Mode)      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"

# Step 1: Validar role
echo -e "${YELLOW}[1/4] Validando IAM Role...${NC}"
LAMBDA_ROLE_ARN="arn:aws:iam::${AWS_ACCOUNT_ID}:role/${LAMBDA_ROLE_NAME}"

if ! aws iam get-role --role-name "$LAMBDA_ROLE_NAME" > /dev/null 2>&1; then
    echo -e "${RED}❌ Role não encontrada: $LAMBDA_ROLE_NAME${NC}"
    exit 1
fi
echo -e "${GREEN}✅ IAM Role válida: $LAMBDA_ROLE_ARN${NC}"

# Step 2: Criar/Atualizar Lambda Function
echo -e "${YELLOW}[2/4] Criando/Atualizando função Lambda...${NC}"

# Criar ZIP do código
zip -j /tmp/finops-lambda.zip lambda_finops_executor.py > /dev/null 2>&1

# Tentar criar nova função
if ! aws lambda get-function --function-name "$LAMBDA_FUNCTION_NAME" --region "$AWS_REGION" > /dev/null 2>&1; then
    echo -e "${BLUE}   Criando nova função Lambda...${NC}"
    aws lambda create-function \
        --function-name "$LAMBDA_FUNCTION_NAME" \
        --runtime python3.11 \
        --role "$LAMBDA_ROLE_ARN" \
        --handler lambda_finops_executor.lambda_handler \
        --zip-file fileb:///tmp/finops-lambda.zip \
        --timeout 300 \
        --memory-size 512 \
        --environment Variables="{SNS_TOPIC_ARN=$SNS_TOPIC_ARN,REGION=$AWS_REGION}" \
        --region "$AWS_REGION" > /dev/null
    echo -e "${GREEN}✅ Função Lambda criada${NC}"
else
    echo -e "${BLUE}   Atualizando função Lambda existente...${NC}"
    aws lambda update-function-code \
        --function-name "$LAMBDA_FUNCTION_NAME" \
        --zip-file fileb:///tmp/finops-lambda.zip \
        --region "$AWS_REGION" > /dev/null
    
    # Atualizar environment variables
    aws lambda update-function-configuration \
        --function-name "$LAMBDA_FUNCTION_NAME" \
        --environment Variables="{SNS_TOPIC_ARN=$SNS_TOPIC_ARN,REGION=$AWS_REGION}" \
        --region "$AWS_REGION" > /dev/null
    echo -e "${GREEN}✅ Função Lambda atualizada${NC}"
fi

sleep 2

# Step 3: Criar EventBridge Rules
echo -e "${YELLOW}[3/4] Configurando EventBridge Rules...${NC}"

LAMBDA_ARN=$(aws lambda get-function --function-name "$LAMBDA_FUNCTION_NAME" --region "$AWS_REGION" --query 'Configuration.FunctionArn' --output text)

# Array de horários
HOURS=("09" "12" "18")

for HOUR in "${HOURS[@]}"; do
    RULE_NAME="linear-hub-finops-${HOUR}h-utc"
    
    # Deletar rule existente se houver
    aws events delete-rule --name "$RULE_NAME" --force --region "$AWS_REGION" 2>/dev/null || true
    sleep 1
    
    # Criar nova rule
    aws events put-rule \
        --name "$RULE_NAME" \
        --schedule-expression "cron(0 $HOUR * * ? *)" \
        --state ENABLED \
        --description "FinOps Cost Extraction at ${HOUR}:00 UTC" \
        --region "$AWS_REGION" > /dev/null
    
    echo -e "${BLUE}   ✓ Rule criada: $RULE_NAME (${HOUR}:00 UTC)${NC}"
    
    # Adicionar Lambda como target
    cat > /tmp/eventbridge-target.json << EOF
[
  {
    "Id": "1",
    "Arn": "$LAMBDA_ARN",
    "RoleArn": "$LAMBDA_ROLE_ARN",
    "Input": "{\"mode\":\"current\",\"send_email\":true}"
  }
]
EOF
    
    aws events put-targets \
        --rule "$RULE_NAME" \
        --targets file:///tmp/eventbridge-target.json \
        --region "$AWS_REGION" > /dev/null
    
    echo -e "${GREEN}   ✅ Target adicionado${NC}"
done

# Step 4: Permitir EventBridge invocar Lambda
echo -e "${YELLOW}[4/4] Configurando permissões Lambda...${NC}"

for HOUR in "${HOURS[@]}"; do
    RULE_NAME="linear-hub-finops-${HOUR}h-utc"
    RULE_ARN="arn:aws:events:${AWS_REGION}:${AWS_ACCOUNT_ID}:rule/${RULE_NAME}"
    
    # Remover policy existente se houver
    aws lambda remove-permission \
        --function-name "$LAMBDA_FUNCTION_NAME" \
        --statement-id "AllowEventBridgeInvoke-${HOUR}h" \
        --region "$AWS_REGION" 2>/dev/null || true
    
    # Adicionar permissão
    aws lambda add-permission \
        --function-name "$LAMBDA_FUNCTION_NAME" \
        --statement-id "AllowEventBridgeInvoke-${HOUR}h" \
        --action lambda:InvokeFunction \
        --principal events.amazonaws.com \
        --source-arn "$RULE_ARN" \
        --region "$AWS_REGION" > /dev/null
done

echo -e "${GREEN}✅ Permissões configuradas${NC}"

# Resumo
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ DEPLOY CONCLUÍDO COM SUCESSO!${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"

echo ""
echo -e "${YELLOW}📊 Configuração Implantada:${NC}"
echo -e "   Lambda Function: ${BLUE}$LAMBDA_FUNCTION_NAME${NC}"
echo -e "   Lambda ARN:      ${BLUE}$LAMBDA_ARN${NC}"
echo -e "   IAM Role:        ${BLUE}$LAMBDA_ROLE_ARN${NC}"
echo -e "   SNS Topic:       ${BLUE}$SNS_TOPIC_ARN${NC}"

echo ""
echo -e "${YELLOW}⏰ Agendamento EventBridge Ativo:${NC}"
echo -e "   ✅ 09:00 UTC - linear-hub-finops-09h-utc"
echo -e "   ✅ 12:00 UTC - linear-hub-finops-12h-utc"
echo -e "   ✅ 18:00 UTC - linear-hub-finops-18h-utc"

echo ""
echo -e "${YELLOW}🧪 Testar Manualmente:${NC}"
echo -e "   ${BLUE}aws lambda invoke --function-name $LAMBDA_FUNCTION_NAME --payload '{\"mode\":\"current\",\"send_email\":true}' /tmp/response.json --region $AWS_REGION && cat /tmp/response.json${NC}"

echo ""
echo -e "${YELLOW}📋 Monitorar CloudWatch Logs:${NC}"
echo -e "   ${BLUE}aws logs tail /aws/lambda/$LAMBDA_FUNCTION_NAME --follow --region $AWS_REGION${NC}"

echo ""
echo -e "${YELLOW}🔍 Ver Eventos EventBridge:${NC}"
echo -e "   ${BLUE}aws events list-rules --region $AWS_REGION | grep linear-hub-finops${NC}"

echo ""
echo -e "${GREEN}🎉 FinOps 100% Server-Side na AWS - Crontab Local Removido!${NC}"

# Cleanup
rm -f /tmp/finops-lambda.zip
