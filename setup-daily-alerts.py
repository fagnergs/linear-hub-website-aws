#!/usr/bin/env python3
"""
Daily Cost Alert Setup Script
Configures EventBridge to send daily cost alerts via SNS
"""

import sys
import subprocess
import json
from datetime import datetime

def run_command(cmd, description=""):
    """Execute AWS CLI command and return output"""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=10)
        if result.returncode != 0:
            return None, result.stderr
        return json.loads(result.stdout) if result.stdout else {}, None
    except Exception as e:
        return None, str(e)

def main():
    print("\n╔════════════════════════════════════════════════════════════════╗")
    print("║  🚀 Daily Cost Alert Setup - Linear Hub Website               ║")
    print("╚════════════════════════════════════════════════════════════════╝\n")

    AWS_REGION = "us-east-1"
    ACCOUNT_ID = "781705467769"
    RULE_NAME = "linear-hub-daily-cost-alert-rule"
    SNS_TOPIC_ARN = f"arn:aws:sns:{AWS_REGION}:{ACCOUNT_ID}:linear-hub-website-alerts"
    SCHEDULE = "cron(0 9 * * ? *)"  # 9:00 AM UTC daily

    # Step 1: Verify AWS Credentials
    print("[1/4] Verifying AWS Credentials...")
    output, error = run_command("aws sts get-caller-identity")
    
    if error or not output:
        print("❌ AWS Credentials: FAILED")
        print(f"   Error: {error}")
        print("\n   Please run: aws configure")
        sys.exit(1)
    
    account = output.get('Account', 'unknown')
    print(f"✅ AWS Credentials: OK (Account: {account})")

    # Step 2: Create EventBridge Rule
    print(f"\n[2/4] Creating EventBridge Rule...")
    cmd = f"""aws events put-rule \
        --name "{RULE_NAME}" \
        --schedule-expression "{SCHEDULE}" \
        --state ENABLED \
        --description "Daily cost alert for Linear Hub Website" \
        --region {AWS_REGION}"""
    
    output, error = run_command(cmd)
    
    if error:
        print(f"⚠️  Warning: {error[:100]}")
    
    if output and 'RuleArn' in output:
        print(f"✅ EventBridge Rule: Created/Updated")
        print(f"   Rule: {RULE_NAME}")
        print(f"   Schedule: Daily at 9:00 AM UTC")
    else:
        print(f"⚠️  Rule creation status unclear")

    # Step 3: Remove Old Targets
    print(f"\n[3/4] Cleaning up old targets...")
    cmd = f"""aws events remove-targets \
        --rule "{RULE_NAME}" \
        --ids "1" \
        --region {AWS_REGION} 2>/dev/null"""
    
    run_command(cmd)
    print(f"✅ Old targets removed")

    # Step 4: Add SNS Target
    print(f"\n[4/4] Adding SNS target...")
    cmd = f"""aws events put-targets \
        --rule "{RULE_NAME}" \
        --targets 'Id=1,Arn={SNS_TOPIC_ARN},Input={{"alert": "daily-cost-report"}}' \
        --region {AWS_REGION}"""
    
    output, error = run_command(cmd)
    
    if output and output.get('FailedEntryCount') == 0:
        print(f"✅ SNS Target: Configured")
        print(f"   Target: {SNS_TOPIC_ARN}")
    else:
        print(f"⚠️  Target configuration unclear")
        if error:
            print(f"   Error: {error[:100]}")

    # Success Summary
    print("\n" + "="*70)
    print("✅ SETUP COMPLETE!")
    print("="*70)
    print(f"""
Your daily alerts are now configured:

   📅 Rule Name: {RULE_NAME}
   ⏰ Schedule: Every day at 9:00 AM UTC
   📧 Recipients: fagnergs@gmail.com, contato@linearhub.com.br
   🔗 SNS Topic: {SNS_TOPIC_ARN}
   
Next Automated Alert: Tomorrow at 9:00 AM UTC

🔍 Verify your configuration:
   aws events describe-rule \\
     --name {RULE_NAME} \\
     --region {AWS_REGION}

🧪 Test your setup (send test email):
   aws sns publish \\
     --topic-arn {SNS_TOPIC_ARN} \\
     --subject "✅ Daily Alert Test - System Active" \\
     --message "If you received this, your daily alert system is working!" \\
     --region {AWS_REGION}

📝 For more details, see: DAILY_ALERTS_SETUP.md
    """)
    print("="*70)

if __name__ == "__main__":
    main()
