#!/usr/bin/env node

/**
 * 🧪 AUTOMATED INTEGRATION TEST
 * Tests all integrations: Email (Resend), Slack, Linear, Notion
 * 
 * Usage: 
 *   node test-all-integrations.js <api-endpoint>
 *   Example: node test-all-integrations.js https://linear-hub.com.br/api/contact
 */

const https = require('https');
const http = require('http');

const API_ENDPOINT = process.argv[2] || 'http://localhost:3000/api/contact';

// Test data
const testContact = {
  name: `🧪 Test User ${new Date().toISOString().split('T')[0]}`,
  email: 'test@example.com',
  company: 'Test Company',
  subject: 'Test Integration - Automated Validation',
  message: 'This is an automated test to validate Email + Slack + Linear + Notion integration. Please ignore this message.',
};

console.log('🧪 AUTOMATED INTEGRATION TEST');
console.log('═══════════════════════════════════════════════════════════════');
console.log(`\n📍 API Endpoint: ${API_ENDPOINT}`);
console.log(`📋 Test Data:`);
console.log(`   Name: ${testContact.name}`);
console.log(`   Email: ${testContact.email}`);
console.log(`   Company: ${testContact.company}`);
console.log(`   Subject: ${testContact.subject}`);
console.log(`\n⏳ Sending test contact form...`);

const payload = JSON.stringify(testContact);
const url = new URL(API_ENDPOINT);

const options = {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(payload),
  },
};

const Protocol = url.protocol === 'https:' ? https : http;

const req = Protocol.request(API_ENDPOINT, options, (res) => {
  let data = '';

  res.on('data', (chunk) => {
    data += chunk;
  });

  res.on('end', () => {
    console.log(`\n✅ Response received (Status: ${res.statusCode})`);
    
    try {
      const response = JSON.parse(data);
      
      if (res.statusCode === 200) {
        console.log('\n🎉 TEST SUCCESSFUL!');
        console.log('═══════════════════════════════════════════════════════════════');
        console.log(`\n✅ HTTP Status: ${res.statusCode} OK`);
        console.log(`✅ Message: ${response.message}`);
        if (response.id) console.log(`✅ Email ID: ${response.id}`);
        
        console.log('\n📊 WHAT SHOULD HAPPEN NOW:');
        console.log('   ✅ Email sent to: contato@linear-hub.com.br (via Resend)');
        console.log('   ✅ Slack notification: #contacts channel');
        console.log('   ✅ Linear task: Created in LWS project');
        console.log('   ✅ Notion page: Created in Contatos database');
        
        console.log('\n🔍 VERIFICATION STEPS:');
        console.log('   1. Check email inbox for test message');
        console.log('   2. Check Slack #contacts for notification');
        console.log('   3. Check Linear LWS project for new task');
        console.log('   4. Check Notion > Linear Hub Website > Contatos database');
        
        console.log('\n📝 Test ID: ' + testContact.name);
        console.log('⏰ Timestamp: ' + new Date().toISOString());
        
        process.exit(0);
      } else {
        console.error(`\n❌ HTTP Error: ${res.statusCode}`);
        console.error(`Error: ${response.error || response.message}`);
        process.exit(1);
      }
    } catch (e) {
      console.error('\n⚠️ Response parsing error');
      console.error('Raw response:', data);
      process.exit(1);
    }
  });
});

req.on('error', (err) => {
  console.error('\n❌ Request failed');
  console.error(`Error: ${err.message}`);
  console.error('\nChecklist:');
  console.error('  ✓ Is the API endpoint correct?');
  console.error('  ✓ Is the server running?');
  console.error('  ✓ Check network connectivity');
  process.exit(1);
});

req.write(payload);
req.end();
