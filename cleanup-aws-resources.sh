#!/bin/bash
# AWS Cleanup Script - INTERACTIVE & SAFE
# This script deletes identified orphaned resources from the audit

set -e

echo "╔════════════════════════════════════════════════════════════════════════╗"
echo "║  AWS RESOURCE CLEANUP - INTERACTIVE MODE                              ║"
echo "║  This script will DELETE identified orphaned resources                 ║"
echo "║  BACKUP: This changes cannot be undone!                               ║"
echo "╚════════════════════════════════════════════════════════════════════════╝"
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
deleted_count=0
failed_count=0

# Function to confirm action
confirm() {
    local prompt="$1"
    local response
    
    read -p "$(echo -e ${YELLOW}${prompt}${NC})" -n 1 -r response
    echo
    if [[ $response =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}

# 1. Delete CloudFormation Stacks
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}STEP 1: CloudFormation Stacks (will delete all contained resources)${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

declare -a cf_stacks=("sam-app" "site-final-definitivo")

for stack in "${cf_stacks[@]}"; do
    echo "Stack: $stack"
    echo "  Resources to be deleted:"
    echo "    - Lambda function"
    echo "    - API Gateway"
    echo "    - Related IAM roles"
    echo "    - CloudWatch logs"
    echo ""
    
    if confirm "Delete CloudFormation stack '$stack'? (y/n): "; then
        echo -e "${YELLOW}Deleting stack: $stack${NC}"
        if aws cloudformation delete-stack --stack-name "$stack" 2>/dev/null; then
            echo -e "${GREEN}✅ Stack deletion initiated: $stack${NC}"
            ((deleted_count++))
        else
            echo -e "${RED}❌ Failed to delete stack: $stack${NC}"
            ((failed_count++))
        fi
    else
        echo "⏭️ Skipped: $stack"
    fi
    echo ""
done

# 2. Delete CloudWatch Log Groups
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}STEP 2: CloudWatch Log Groups (orphaned)${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

declare -a log_groups=("/aws/lambda/jsmc-contact-form-handler")

for log_group in "${log_groups[@]}"; do
    echo "Log Group: $log_group"
    echo "  Reason: No corresponding Lambda function"
    echo ""
    
    if confirm "Delete log group '$log_group'? (y/n): "; then
        echo -e "${YELLOW}Deleting log group: $log_group${NC}"
        if aws logs delete-log-group --log-group-name "$log_group" 2>/dev/null; then
            echo -e "${GREEN}✅ Log group deleted: $log_group${NC}"
            ((deleted_count++))
        else
            echo -e "${RED}❌ Failed to delete log group: $log_group${NC}"
            ((failed_count++))
        fi
    else
        echo "⏭️ Skipped: $log_group"
    fi
    echo ""
done

# 3. Delete S3 Buckets
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}STEP 3: S3 Buckets (orphaned - will empty first)${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

declare -a s3_buckets=("jsmc.com.br" "www.jsmc.com.br")

for bucket in "${s3_buckets[@]}"; do
    echo "Bucket: $bucket"
    echo "  Reason: Orphaned, not connected to any active resources"
    echo ""
    
    if confirm "Delete S3 bucket '$bucket'? (y/n): "; then
        echo -e "${YELLOW}Emptying bucket: $bucket${NC}"
        if aws s3 rm s3://"$bucket" --recursive --quiet 2>/dev/null; then
            echo -e "${GREEN}✅ Bucket emptied: $bucket${NC}"
            
            echo -e "${YELLOW}Deleting bucket: $bucket${NC}"
            if aws s3api delete-bucket --bucket "$bucket" 2>/dev/null; then
                echo -e "${GREEN}✅ Bucket deleted: $bucket${NC}"
                ((deleted_count++))
            else
                echo -e "${RED}❌ Failed to delete bucket: $bucket${NC}"
                ((failed_count++))
            fi
        else
            echo -e "${RED}❌ Failed to empty bucket: $bucket${NC}"
            ((failed_count++))
        fi
    else
        echo "⏭️ Skipped: $bucket"
    fi
    echo ""
done

# 4. Optional: Delete ACM Certificate
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}STEP 4: ACM Certificate (optional - not in use)${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

echo "Certificate: jsmc.com.br"
echo "ARN: arn:aws:acm:us-east-1:781705467769:certificate/332f5a47-3c9b-4fec-aba8-02a891a035ec"
echo "Status: Not in use by any CloudFront distribution"
echo "Note: Keeping unused certificates has no cost"
echo ""

if confirm "Delete unused ACM certificate 'jsmc.com.br'? (y/n): "; then
    echo -e "${YELLOW}Deleting certificate${NC}"
    if aws acm delete-certificate --certificate-arn "arn:aws:acm:us-east-1:781705467769:certificate/332f5a47-3c9b-4fec-aba8-02a891a035ec" 2>/dev/null; then
        echo -e "${GREEN}✅ Certificate deleted${NC}"
        ((deleted_count++))
    else
        echo -e "${RED}❌ Failed to delete certificate${NC}"
        ((failed_count++))
    fi
else
    echo "⏭️ Skipped: ACM certificate"
fi
echo ""

# Summary
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}CLEANUP SUMMARY${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}✅ Successfully deleted: $deleted_count resources${NC}"
if [ $failed_count -gt 0 ]; then
    echo -e "${RED}❌ Failed to delete: $failed_count resources${NC}"
fi
echo ""

# Verification
echo -e "${YELLOW}⏳ Waiting for CloudFormation deletions to propagate (30 seconds)...${NC}"
sleep 30

echo ""
echo -e "${BLUE}VERIFICATION: Remaining resources${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

echo "CloudFormation Stacks:"
aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE \
    --query 'StackSummaries[?StackName!=`aws-sam-cli-managed-default`].[StackName,StackStatus]' \
    --output table || echo "  ✅ No stacks found"

echo ""
echo "S3 Buckets:"
aws s3api list-buckets --query 'Buckets[?Name!=`aws-sam-cli-managed-default-samclisourcebucket-kxmjw6eibxwt`].Name' \
    --output text || echo "  ✅ Only production bucket remains"

echo ""
echo -e "${GREEN}✅ CLEANUP COMPLETE${NC}"
echo ""
echo "Next steps:"
echo "  1. Verify site is still working: https://linear-hub.com.br"
echo "  2. Check CloudWatch for any errors in linear-hub-contact-api logs"
echo "  3. Monitor CloudFront metrics for any anomalies"
echo ""
