# AWS Setup: Lambda + S3 + CloudFront

**Application:** Linear Hub Website
**Environment:** Production
**Region:** us-east-1 (CloudFront requires)
**Start Date:** 2025-12-12
**Budget:** $200 credit (until 2026-11-14)

---

## 📋 Tagging Strategy

All AWS resources tagged with:

```
Application: linear-hub-website
Environment: production
Tenant: linear-hub
ManagedBy: terraform/manual
CostCenter: linear-hub
```

---

## Phase 1: IAM Setup & Security

### ✅ Step 1.1: Create IAM User (linear-hub-deployer)

**Why:** Never use root credentials. Principle of least privilege.

```bash
# Create user
aws iam create-user --user-name linear-hub-deployer \
  --tags Key=Application,Value=linear-hub-website Key=Tenant,Value=linear-hub

# Create access keys (will display once!)
aws iam create-access-key --user-name linear-hub-deployer
```

**Save output securely:**
- Access Key ID: `AKIA...`
- Secret Access Key: `...` (KEEP SAFE!)

### ✅ Step 1.2: Create IAM Policy (linear-hub-deployer-policy)

Policy allows:
- S3: Upload to bucket, invalidate CDN
- Lambda: Create/update functions
- API Gateway: Create/manage
- CloudFront: Invalidate cache
- CloudWatch: Logs
- Route53: Manage DNS records

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "S3DeployPermissions",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::linear-hub-website",
        "arn:aws:s3:::linear-hub-website/*"
      ]
    },
    {
      "Sid": "CloudFrontInvalidate",
      "Effect": "Allow",
      "Action": [
        "cloudfront:CreateInvalidation",
        "cloudfront:GetInvalidation"
      ],
      "Resource": "arn:aws:cloudfront::ACCOUNT_ID:distribution/E..."
    },
    {
      "Sid": "LambdaPermissions",
      "Effect": "Allow",
      "Action": [
        "lambda:UpdateFunctionCode",
        "lambda:UpdateFunctionConfiguration",
        "lambda:GetFunction",
        "lambda:PublishVersion"
      ],
      "Resource": "arn:aws:lambda:us-east-1:ACCOUNT_ID:function:linear-hub-contact-api"
    },
    {
      "Sid": "APIGatewayPermissions",
      "Effect": "Allow",
      "Action": [
        "apigateway:POST",
        "apigateway:PUT",
        "apigateway:PATCH"
      ],
      "Resource": "arn:aws:apigateway:us-east-1::/restapis/*"
    },
    {
      "Sid": "CloudWatchLogs",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:us-east-1:ACCOUNT_ID:log-group:/aws/lambda/linear-hub-*"
    },
    {
      "Sid": "Route53Permissions",
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets",
        "route53:GetChange"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/Z...",
        "arn:aws:route53:::change/*"
      ]
    }
  ]
}
```

### ✅ Step 1.3: Attach Policy to User

```bash
aws iam put-user-policy --user-name linear-hub-deployer \
  --policy-name linear-hub-deployer-policy \
  --policy-document file://policy.json
```

### ✅ Step 1.4: Create MFA for Root User

```bash
# Register MFA device on root account
# Recommended: Use hardware key (Yubikey) or authenticator app
```

### ✅ Step 1.5: Enable Billing Alerts

```bash
# CloudWatch alarm: Alert when spending exceeds $150 (preserve $50 buffer)
```

---

## Phase 2: S3 + CloudFront Setup

### ✅ Step 2.1: Create S3 Bucket

```bash
BUCKET_NAME="linear-hub-website-prod-$(date +%s)"

aws s3api create-bucket \
  --bucket $BUCKET_NAME \
  --region us-east-1 \
  --tags 'TagSet=[{Key=Application,Value=linear-hub-website},{Key=Environment,Value=production},{Key=Tenant,Value=linear-hub}]'
```

### ✅ Step 2.2: Configure S3 for Static Site

```bash
# Block public access
aws s3api put-public-access-block \
  --bucket $BUCKET_NAME \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket $BUCKET_NAME \
  --versioning-configuration Status=Enabled

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket $BUCKET_NAME \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'
```

### ✅ Step 2.3: Create CloudFront Distribution

- Origin: S3 bucket
- Cache: 1 year for assets, 5 min for HTML
- HTTPS: Automatic (CloudFront cert)
- Custom domain: linear-hub.com.br
- OAI: Origin Access Identity (S3 only via CF)

---

## Phase 3: Lambda + API Gateway

### ✅ Step 3.1: Create Lambda Function (linear-hub-contact-api)

- Runtime: Node.js 20
- Handler: `index.handler`
- Memory: 256MB
- Timeout: 30s
- Environment: `RESEND_API_KEY`

### ✅ Step 3.2: Create API Gateway

- REST API
- Method: POST /contact
- Integration: Lambda
- CORS enabled
- Throttling: 100 requests/second

---

## Phase 4: GitHub Actions Integration

### ✅ Step 4.1: Store AWS Credentials in GitHub Secrets

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_REGION = us-east-1
CLOUDFRONT_DISTRIBUTION_ID = E...
S3_BUCKET = linear-hub-website-prod-...
RESEND_API_KEY = re_...
```

### ✅ Step 4.2: Create GitHub Actions Workflow

On push to main:
1. Build: `npm run build` → static HTML in `.next`
2. Upload S3: Sync to bucket
3. Invalidate: CloudFront cache
4. Notify: Slack (later)

---

## Checklist

- [ ] IAM user created (linear-hub-deployer)
- [ ] IAM policy created and attached
- [ ] MFA enabled on root account
- [ ] S3 bucket created with encryption
- [ ] CloudFront distribution configured
- [ ] Lambda function created
- [ ] API Gateway endpoint configured
- [ ] Route53 DNS records updated
- [ ] GitHub Secrets configured
- [ ] GitHub Actions workflow created
- [ ] SSL certificate provisioned
- [ ] Site tested and live

---

## Cost Projection

| Service | Monthly | Annual | Notes |
|---------|---------|--------|-------|
| S3 | $1-2 | $12-24 | Storage + requests |
| CloudFront | $5-10 | $60-120 | Low traffic |
| Lambda | $0 | $0 | Free tier |
| API Gateway | $0 | $0 | Free tier |
| Route53 | $0.50 | $6 | Hosted zone |
| **Total** | **$6-13** | **$72-150** | **$200 credit ≈ 16-32 months free** |

---

## References

- AWS IAM Best Practices: https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html
- S3 Security: https://docs.aws.amazon.com/AmazonS3/latest/userguide/security.html
- CloudFront: https://docs.aws.amazon.com/cloudfront/
- Lambda: https://docs.aws.amazon.com/lambda/
