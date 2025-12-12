# 🔐 AWS Credentials & Setup Values

**Created:** 2025-12-12 12:47 UTC  
**Status:** ✅ SETUP COMPLETE

---

## 1️⃣ AWS Account

| Property | Value |
|----------|-------|
| AWS Account ID | `781705467769` |
| Region | `us-east-1` |

---

## 2️⃣ IAM User (linear-hub-deployer)

| Property | Value |
|----------|-------|
| Username | `linear-hub-deployer` |
| ARN | `arn:aws:iam::781705467769:user/linear-hub-deployer` |
| User ID | `AIDA3MAKG254TAEHZWPS3` |
| Created | 2025-12-12T12:45:54+00:00 |
| Tags | Application: linear-hub-website, Tenant: linear-hub |

### Attached Policy
- **Policy Name:** `linear-hub-deployment-policy`
- **Permissions:** S3, CloudFront, Lambda, CloudWatch (least-privilege)
- **File:** `aws/iam-policy.json`

---

## 3️⃣ S3 Bucket

| Property | Value |
|----------|-------|
| Bucket Name | `linear-hub-website-prod-1765543563` |
| Region | `us-east-1` |
| Versioning | ✅ Enabled |
| Encryption | ✅ AES256 |
| Public Access | ✅ Blocked |
| Tags | Application: linear-hub-website, Environment: production, Tenant: linear-hub, ManagedBy: terraform, CostCenter: website |

### Security Configuration
- **Block Public ACLs:** Yes
- **Ignore Public ACLs:** Yes
- **Block Public Policy:** Yes
- **Restrict Public Buckets:** Yes

---

## 4️⃣ IAM Access Keys

| Property | Value |
|----------|-------|
| Access Key ID | `AKIA3MAKG254WXDUQLLZ` |
| Secret Access Key | `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` |
| Status | ✅ Active |
| Created | 2025-12-12T12:47:02+00:00 |

⚠️ **IMPORTANT:** Save these credentials securely. You'll need them for GitHub Secrets.

---

## 5️⃣ Next Steps

### Step 1: Create CloudFront Distribution (Manual)
1. Go to AWS CloudFront console
2. Create distribution with:
   - Origin: `linear-hub-website-prod-1765543563.s3.us-east-1.amazonaws.com`
   - Origin Access Identity (OAI): New
   - Default Root Object: `index.html`
   - Custom domain: `linear-hub.com.br` (after DNS update)
3. **Save:** Distribution ID (e.g., `E2XXXX`)

### Step 2: Create Lambda Function (Manual)
1. Go to AWS Lambda console
2. Create function:
   - Name: `linear-hub-contact-api`
   - Runtime: Node.js 20.x
   - Code: Copy from `aws/lambda/index.js`
   - Environment variable: `RESEND_API_KEY=<your-resend-key>`
3. **Save:** Function ARN

### Step 3: Create API Gateway (Manual)
1. Go to AWS API Gateway console
2. Create REST API:
   - Name: `linear-hub-api`
   - Method: POST
   - Path: `/contact`
   - Integration: Lambda function `linear-hub-contact-api`
3. **Save:** API Invoke URL (e.g., `https://xxxxx.execute-api.us-east-1.amazonaws.com/prod/contact`)

### Step 4: Add GitHub Secrets
Go to GitHub repository settings → Secrets and add:

```
AWS_ACCESS_KEY_ID=AKIA3MAKG254WXDUQLLZ
AWS_SECRET_ACCESS_KEY=nGdnwzpuGFut+UaeC3j5uA7YCXwIt4R14wv1MNwU
AWS_REGION=us-east-1
S3_BUCKET=linear-hub-website-prod-1765543563
CLOUDFRONT_DISTRIBUTION_ID=<YOUR_DISTRIBUTION_ID>
LAMBDA_FUNCTION_NAME=linear-hub-contact-api
RESEND_API_KEY=<YOUR_RESEND_KEY>
```

### Step 5: Update DNS
Update your domain registrar (where linear-hub.com.br is hosted):

```
Type: A / CNAME
Name: linear-hub.com.br
Value: <CloudFront_Domain_Name>
TTL: 300 (5 minutes)
```

### Step 6: Deploy
```bash
git push origin main
```

Monitor GitHub Actions → Deploy workflow

---

## 🔒 Security Notes

1. **Rotate credentials every 90 days:**
   ```bash
   aws iam create-access-key --user-name linear-hub-deployer
   aws iam delete-access-key --user-name linear-hub-deployer --access-key-id <OLD_KEY>
   ```

2. **Monitor IAM user activity:**
   ```bash
   aws iam get-user --user-name linear-hub-deployer
   aws iam list-access-keys --user-name linear-hub-deployer
   ```

3. **Enable CloudTrail logging** for audit trail

4. **Use AWS Secrets Manager** for sensitive credentials in future

---

## 📊 Cost Tracking

| Service | Estimate | Notes |
|---------|----------|-------|
| S3 | $1-2/month | Storage + requests |
| CloudFront | $5-10/month | Data transfer |
| Lambda | $0 | Free tier (1M requests/month) |
| API Gateway | $0 | Free tier (1M requests/month) |
| Route53 | $0.50 | DNS hosting |
| **Total** | **$6-13/month** | **Free tier covers all** |

**AWS Credit: $200 remaining (expires 2026-11-14)**  
**Coverage: ~16-32 months** 🎉

---

## ✅ Checklist

- [x] AWS Account verified
- [x] IAM User created (linear-hub-deployer)
- [x] S3 Bucket created and configured
- [x] Access Keys generated
- [x] IAM Policy attached
- [ ] CloudFront Distribution created
- [ ] Lambda Function created
- [ ] API Gateway endpoint created
- [ ] GitHub Secrets configured
- [ ] DNS records updated
- [ ] First deployment tested
- [ ] Email notifications verified

---

**Last Updated:** 2025-12-12  
**Maintainer:** Fagner GS  
**Repository:** https://github.com/fagnergs/linear-hub-website-aws
