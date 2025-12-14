#!/usr/bin/env node

/**
 * Test Notion Integration
 * Quick test to validate Notion setup without re-deploying
 */

const https = require('https');

// Get credentials from environment
const NOTION_API_KEY = process.env.NOTION_API_KEY;
const NOTION_CONTACTS_DB = process.env.NOTION_CONTACTS_DATABASE_ID;

console.log('🧪 NOTION INTEGRATION TEST');
console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

// Validate credentials
console.log('\n1️⃣ Checking credentials...');
if (!NOTION_API_KEY) {
  console.error('❌ NOTION_API_KEY not set');
  process.exit(1);
}
console.log('✅ NOTION_API_KEY: ' + NOTION_API_KEY.substring(0, 20) + '...');

if (!NOTION_CONTACTS_DB) {
  console.error('❌ NOTION_CONTACTS_DATABASE_ID not set');
  process.exit(1);
}
console.log('✅ NOTION_CONTACTS_DATABASE_ID: ' + NOTION_CONTACTS_DB);

// Test 1: Create a test page
console.log('\n2️⃣ Creating test page in Notion...');

const testData = {
  parent: { database_id: NOTION_CONTACTS_DB },
  properties: {
    Name: {
      title: [{ text: { content: '🧪 Test Contact - ' + new Date().toISOString() } }],
    },
    Email: {
      email: 'test@example.com',
    },
    Company: {
      rich_text: [{ text: { content: 'Test Company' } }],
    },
    Subject: {
      rich_text: [{ text: { content: 'Test Subject - Integration Validation' } }],
    },
    Message: {
      rich_text: [{ text: { content: 'This is a test message to validate Notion integration is working correctly.' } }],
    },
    Created: {
      date: { start: new Date().toISOString() },
    },
    Status: {
      select: { name: 'new' },
    },
  },
};

const payload = JSON.stringify(testData);

const options = {
  hostname: 'api.notion.com',
  path: '/v1/pages',
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${NOTION_API_KEY}`,
    'Content-Type': 'application/json',
    'Notion-Version': '2022-06-28',
    'Content-Length': Buffer.byteLength(payload),
  },
};

const req = https.request(options, (res) => {
  let data = '';

  res.on('data', (chunk) => {
    data += chunk;
  });

  res.on('end', () => {
    console.log('\n📊 Response Status: ' + res.statusCode);

    try {
      const response = JSON.parse(data);
      
      if (res.statusCode === 200) {
        console.log('✅ Page created successfully in Notion');
        console.log('   Page ID: ' + response.id);
        console.log('   URL: https://www.notion.so/' + response.id.replace(/-/g, ''));
        
        console.log('\n✅ NOTION INTEGRATION WORKING PERFECTLY');
        console.log('\n🎉 You can now test with the form on your website!');
        process.exit(0);
      } else {
        console.error('❌ Notion API Error');
        console.error('   Status: ' + res.statusCode);
        console.error('   Message: ' + (response.message || response));
        
        if (response.code === 'unauthorized') {
          console.error('\n💡 Hint: Check if your NOTION_API_KEY is correct');
        } else if (response.code === 'invalid_request_body') {
          console.error('\n💡 Hint: Check if your database properties match the expected format');
        }
        process.exit(1);
      }
    } catch (e) {
      console.error('❌ Failed to parse response');
      console.error('   Raw: ' + data.substring(0, 200));
      process.exit(1);
    }
  });
});

req.on('error', (err) => {
  console.error('❌ Request error:', err.message);
  process.exit(1);
});

req.write(payload);
req.end();
