#!/bin/bash

################################################################################
# Deploy FinOps Lambda + EventBridge via CloudFormation
# Expert AWS - Automated Setup
################################################################################

set -e

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configurações
AWS_REGION="us-east-1"
AWS_ACCOUNT_ID="781705467769"
SNS_TOPIC_ARN="arn:aws:sns:us-east-1:781705467769:linear-hub-website-alerts"
STACK_NAME="linear-hub-finops-stack"
LAMBDA_ROLE_NAME="linear-hub-lambda-execution"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Deploy FinOps Lambda + EventBridge - Expert AWS Setup        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"

# Step 1: Verificar credenciais AWS
echo -e "${YELLOW}[1/5] Verificando credenciais AWS...${NC}"
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    echo -e "${RED}❌ Erro: Credenciais AWS não configuradas${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Credenciais AWS validadas${NC}"

# Step 2: Criar/Verificar IAM Role para Lambda
echo -e "${YELLOW}[2/5] Configurando IAM Role para Lambda...${NC}"

# Verificar se role existe
if ! aws iam get-role --role-name "$LAMBDA_ROLE_NAME" > /dev/null 2>&1; then
    echo -e "${BLUE}   Criando nova IAM Role...${NC}"
    
    # Trust policy para Lambda
    cat > /tmp/lambda-trust-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

    aws iam create-role \
        --role-name "$LAMBDA_ROLE_NAME" \
        --assume-role-policy-document file:///tmp/lambda-trust-policy.json \
        --region "$AWS_REGION" || true

    # Attach policies
    echo -e "${BLUE}   Adicionando permissões...${NC}"
    
    # Policy para Cost Explorer e SNS
    cat > /tmp/lambda-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ce:GetCostAndUsage"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "sns:Publish"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
EOF

    aws iam put-role-policy \
        --role-name "$LAMBDA_ROLE_NAME" \
        --policy-name "linear-hub-finops-policy" \
        --policy-document file:///tmp/lambda-policy.json

    sleep 5  # Aguardar propagação de IAM
    echo -e "${GREEN}✅ IAM Role criada com sucesso${NC}"
else
    echo -e "${GREEN}✅ IAM Role já existe${NC}"
fi

# Step 3: Preparar código Lambda
echo -e "${YELLOW}[3/5] Preparando código Lambda...${NC}"

LAMBDA_CODE_FILE="lambda_finops_executor.py"
if [ ! -f "$LAMBDA_CODE_FILE" ]; then
    echo -e "${RED}❌ Erro: Arquivo $LAMBDA_CODE_FILE não encontrado${NC}"
    exit 1
fi

# Criar ZIP com código Lambda
zip -q finops-lambda.zip "$LAMBDA_CODE_FILE" || true
echo -e "${GREEN}✅ Código Lambda preparado (finops-lambda.zip)${NC}"

# Step 4: Deploy CloudFormation Stack
echo -e "${YELLOW}[4/5] Fazendo deploy do CloudFormation Stack...${NC}"

LAMBDA_ROLE_ARN="arn:aws:iam::${AWS_ACCOUNT_ID}:role/${LAMBDA_ROLE_NAME}"

# Validar template
aws cloudformation validate-template \
    --template-body file://cloudformation-finops.yml \
    --region "$AWS_REGION" > /dev/null

# Deploy stack
aws cloudformation deploy \
    --template-file cloudformation-finops.yml \
    --stack-name "$STACK_NAME" \
    --parameter-overrides \
        SNSTopicArn="$SNS_TOPIC_ARN" \
        LambdaExecutionRole="$LAMBDA_ROLE_ARN" \
    --region "$AWS_REGION" \
    --no-fail-on-empty-changeset \
    --capabilities CAPABILITY_NAMED_IAM

echo -e "${GREEN}✅ CloudFormation Stack deployed${NC}"

# Step 5: Atualizar código Lambda com ZIP
echo -e "${YELLOW}[5/5] Atualizando função Lambda com código...${NC}"

LAMBDA_FUNCTION_NAME="linear-hub-finops-cost-extractor"

aws lambda update-function-code \
    --function-name "$LAMBDA_FUNCTION_NAME" \
    --zip-file fileb://finops-lambda.zip \
    --region "$AWS_REGION" > /dev/null

echo -e "${GREEN}✅ Código Lambda atualizado${NC}"

# Verificação final
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ DEPLOY CONCLUÍDO COM SUCESSO!${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"

echo ""
echo -e "${YELLOW}📊 Informações de Deploy:${NC}"
echo -e "   Stack Name:           ${BLUE}$STACK_NAME${NC}"
echo -e "   Lambda Function:      ${BLUE}$LAMBDA_FUNCTION_NAME${NC}"
echo -e "   IAM Role:             ${BLUE}$LAMBDA_ROLE_NAME${NC}"
echo -e "   SNS Topic:            ${BLUE}$SNS_TOPIC_ARN${NC}"
echo -e "   AWS Region:           ${BLUE}$AWS_REGION${NC}"

echo ""
echo -e "${YELLOW}⏰ Agendamento EventBridge:${NC}"
echo -e "   09:00 UTC - linear-hub-finops-09h-utc"
echo -e "   12:00 UTC - linear-hub-finops-12h-utc"
echo -e "   18:00 UTC - linear-hub-finops-18h-utc"

echo ""
echo -e "${YELLOW}🔍 Próximos passos:${NC}"
echo -e "   1. Verificar CloudWatch Logs:"
echo -e "      ${BLUE}aws logs tail /aws/lambda/$LAMBDA_FUNCTION_NAME --follow${NC}"
echo -e ""
echo -e "   2. Testar manualmente:"
echo -e "      ${BLUE}aws lambda invoke --function-name $LAMBDA_FUNCTION_NAME /tmp/response.json && cat /tmp/response.json${NC}"
echo -e ""
echo -e "   3. Ver detalhes do Stack:"
echo -e "      ${BLUE}aws cloudformation describe-stacks --stack-name $STACK_NAME${NC}"
echo -e ""
echo -e "   4. Remover CloudFormation Stack (quando quiser):"
echo -e "      ${BLUE}aws cloudformation delete-stack --stack-name $STACK_NAME${NC}"

echo ""
echo -e "${GREEN}🎉 FinOps agora rodando 100% server-side na AWS!${NC}"

# Cleanup
rm -f /tmp/lambda-trust-policy.json /tmp/lambda-policy.json finops-lambda.zip
