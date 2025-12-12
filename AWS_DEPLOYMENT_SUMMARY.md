# AWS Deployment Summary

**Created:** Fri Dec 12 09:50:51 -03 2025

## CloudFront Distribution
- **ID:** EDQZRUQFXIMQ6
- **Domain:** d1dmp1hz6w68o3.cloudfront.net
- **OAI ID:** EURJX2QGAC4FV
- **Status:** Deploying (5-10 minutes)

## Lambda Function
- **Name:** linear-hub-contact-api
- **ARN:** arn:aws:lambda:us-east-1:781705467769:function:linear-hub-contact-api
- **Role ARN:** arn:aws:iam::781705467769:role/linear-hub-lambda-role
- **Runtime:** nodejs20.x
- **Memory:** 256 MB
- **Timeout:** 30 seconds

## API Gateway
- **API ID:** xsp6ymu9u6
- **Endpoint:** https://xsp6ymu9u6.execute-api.us-east-1.amazonaws.com/prod/contact
- **Method:** POST /contact
- **Deployment ID:** m8qmqn

## GitHub Secrets Required
```
AWS_ACCESS_KEY_ID=<from-AWS_CREDENTIALS.md>
AWS_SECRET_ACCESS_KEY=<from-AWS_CREDENTIALS.md>
AWS_REGION=us-east-1
S3_BUCKET=linear-hub-website-prod-1765543563
CLOUDFRONT_DISTRIBUTION_ID=EDQZRUQFXIMQ6
LAMBDA_FUNCTION_NAME=linear-hub-contact-api
RESEND_API_KEY=<your-resend-key>
```

## DNS Configuration
Update your domain registrar:
```
A Record: linear-hub.com.br → d1dmp1hz6w68o3.cloudfront.net
CNAME Record: www.linear-hub.com.br → d1dmp1hz6w68o3.cloudfront.net
```

## Environment Variables to Update
Update `.env.production` or GitHub Secrets:
```
NEXT_PUBLIC_API_ENDPOINT=https://xsp6ymu9u6.execute-api.us-east-1.amazonaws.com/prod/contact
RESEND_API_KEY=<your-resend-key>
```
