# AWS Lambda + S3 + CloudFront Deployment Guide

**Quick Start:** Leia isto antes de começar!

---

## Prerequisites

- ✅ AWS Account com $200 crédito
- ✅ AWS CLI instalado (`aws --version`)
- ✅ GitHub CLI instalado (`gh --version`)
- ✅ Resend account com API key
- ✅ Domínio linear-hub.com.br já registrado

---

## 🚀 Quick Setup (15 min)

### 1. Configure AWS CLI

```bash
# Configure AWS credentials
aws configure

# When prompted, use your AWS Access Key ID & Secret Access Key
# Region: us-east-1
# Output format: json
```

**⚠️ IMPORTANT:** 
- Use IAM user credentials, NOT root account
- Never commit credentials to git
- Store securely (password manager)

### 2. Run AWS Setup Script

```bash
cd /Users/fagnergs/Documents/GitHub/linear-hub-website-aws

# Make script executable
chmod +x aws/setup.sh

# Run setup
./aws/setup.sh
```

**Output:**
- S3 bucket name (e.g., `linear-hub-website-prod-1702458123`)
- AWS Account ID
- IAM user created

**SAVE THESE VALUES!**

### 3. Create IAM Access Keys

```bash
# Replace with actual username
aws iam create-access-key --user-name linear-hub-deployer

# Output will show:
# {
#   "AccessKey": {
#     "AccessKeyId": "AKIA...",
#     "SecretAccessKey": "..." 
#   }
# }
```

**🔐 CRITICAL:** Copy these values immediately! They won't be shown again.

### 4. Attach IAM Policy

```bash
aws iam put-user-policy \
  --user-name linear-hub-deployer \
  --policy-name linear-hub-deployer-policy \
  --policy-document file://aws/iam-policy.json
```

### 5. Create CloudFront Distribution (Manual via AWS Console)

AWS Console → CloudFront → Create Distribution

**Settings:**
- Origin: Select S3 bucket created earlier
- Origin Access Control: Create new OAC
- Default Root Object: `index.html`
- Viewer Protocol: Redirect HTTP to HTTPS
- Caching: Default (1 day)
- Custom Domain: `linear-hub.com.br`
- SSL Certificate: Request new (ACM)

**After creation, copy Distribution ID (e.g., `E1A2B3C4D5E6F`)** ← Save this!

### 6. Add GitHub Secrets

```bash
# Open GitHub repo settings
gh repo view --web

# Settings → Secrets and variables → Actions → New repository secret
```

Add these secrets:

```
AWS_ACCESS_KEY_ID=AKIA...
AWS_SECRET_ACCESS_KEY=...
AWS_REGION=us-east-1
S3_BUCKET=linear-hub-website-prod-1702458123
CLOUDFRONT_DISTRIBUTION_ID=E1A2B3C4D5E6F
LAMBDA_FUNCTION_NAME=linear-hub-contact-api
RESEND_API_KEY=re_...
```

### 7. Update DNS Records

Domain registrar → DNS Settings

Add/update these records:

```
Type: A
Name: linear-hub.com.br
Value: CloudFront Domain Name (e.g., d111111abcdef8.cloudfront.net)

Type: A
Name: www
Value: Same CloudFront domain
(or CNAME to linear-hub.com.br)
```

Propagation: 5-30 minutes

### 8. Create Lambda Function (Manual)

AWS Console → Lambda → Create function

**Settings:**
- Function name: `linear-hub-contact-api`
- Runtime: Node.js 20.x
- Architecture: x86_64
- Handler: `index.handler`

**Environment Variables:**
```
RESEND_API_KEY=re_...
```

**Upload code:**
```bash
# Package Lambda function
cd aws/lambda
zip -r function.zip index.js package.json
# Upload via console or AWS CLI
```

### 9. Create API Gateway

AWS Console → API Gateway → Create API

**Settings:**
- Type: REST API
- Name: `linear-hub-api`
- CORS: Enable
- Method: POST
- Path: `/contact`
- Integration: Lambda → `linear-hub-contact-api`

**Get the API endpoint URL** ← Save this!

### 10. Update Next.js Config

In your application, update contact form API URL:

```javascript
// components/sections/Contact.tsx
const API_ENDPOINT = 'https://API_GATEWAY_URL/contact'

// Replace with actual URL from step 9
```

### 11. Deploy!

```bash
git add .
git commit -m "feat: add AWS Lambda setup and GitHub Actions"
git push origin main
```

GitHub Actions will:
1. ✅ Build Next.js (`npm run build`)
2. ✅ Upload to S3
3. ✅ Invalidate CloudFront
4. ✅ Deploy Lambda (if configured)

**Check:** https://github.com/fagnergs/linear-hub-website-aws/actions

### 12. Verify Deployment

```bash
# Test S3/CloudFront
curl -I https://linear-hub.com.br/

# Test API
curl -X POST https://API_GATEWAY_URL/contact \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test",
    "email": "test@example.com",
    "subject": "Test",
    "message": "Test message"
  }'
```

---

## 📊 Cost Monitoring

```bash
# Set budget alert
aws budgets create-budget \
  --account-id $(aws sts get-caller-identity --query Account --output text) \
  --budget file://aws/budget.json \
  --notifications-with-subscribers file://aws/notifications.json
```

**Monthly estimate with low traffic:**
- S3: $1-2
- CloudFront: $5-10
- Lambda: $0 (free tier)
- API Gateway: $0 (free tier)
- **Total: ~$6-12/mês**

---

## 🔒 Security Best Practices

- [ ] Enable MFA on root account
- [ ] Rotate IAM credentials every 90 days
- [ ] Use AWS Secrets Manager for sensitive values
- [ ] Enable CloudTrail for audit logs
- [ ] Set up CloudWatch alarms for unusual activity
- [ ] Review S3 bucket policy (block public access)

---

## Troubleshooting

### S3 Upload Fails
```bash
# Check bucket permissions
aws s3 ls s3://YOUR_BUCKET_NAME/

# Fix permissions
aws s3api put-bucket-policy --bucket YOUR_BUCKET_NAME --policy file://aws/s3-policy.json
```

### CloudFront Not Updating
```bash
# Manual invalidation
aws cloudfront create-invalidation \
  --distribution-id YOUR_DISTRIBUTION_ID \
  --paths "/*"
```

### Lambda Cold Start
Add to CloudWatch Events to keep warm (optional):
```bash
# Invoke Lambda every 5 minutes
```

---

## References

- [AWS Lambda Documentation](https://docs.aws.amazon.com/lambda/)
- [S3 & CloudFront Setup](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/distribution-web-awsamazon_s3origin.html)
- [API Gateway](https://docs.aws.amazon.com/apigateway/)
- [AWS CLI Cheat Sheet](https://docs.aws.amazon.com/cli/latest/)

---

## Support

Issues? Check:
1. CloudWatch Logs (Lambda function logs)
2. AWS Console for service status
3. GitHub Actions workflow logs
4. CloudFront cache invalidation status

---

**Questions?** Open an issue in the repository.
