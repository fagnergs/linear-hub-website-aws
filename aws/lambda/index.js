// AWS Lambda Function: Contact API
// Handles POST requests to /api/contact
// Sends emails via Resend API

const https = require('https');

const RESEND_API_KEY = process.env.RESEND_API_KEY;
const CONTACT_EMAIL = 'contato@linear-hub.com.br';

exports.handler = async (event) => {
  console.log('Received event:', JSON.stringify(event, null, 2));

  // Only allow POST
  if (event.httpMethod !== 'POST') {
    return {
      statusCode: 405,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ error: 'Method Not Allowed' }),
    };
  }

  try {
    // Parse request body
    let body;
    if (typeof event.body === 'string') {
      body = JSON.parse(event.body);
    } else {
      body = event.body;
    }

    const { name, email, company, subject, message } = body;

    // Validate required fields
    if (!name || !email || !subject || !message) {
      return {
        statusCode: 400,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          error: 'Missing required fields: name, email, subject, message',
        }),
      };
    }

    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return {
        statusCode: 400,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ error: 'Invalid email format' }),
      };
    }

    // Prepare email HTML
    const emailHTML = `
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="UTF-8">
          <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background: linear-gradient(135deg, #1890ff 0%, #13c2c2 100%); color: white; padding: 20px; border-radius: 5px 5px 0 0; }
            .content { background: #f9f9f9; padding: 20px; border-radius: 0 0 5px 5px; }
            .field { margin: 15px 0; }
            .label { font-weight: bold; color: #1890ff; }
            .value { margin-top: 5px; padding: 10px; background: white; border-left: 3px solid #13c2c2; }
            .footer { margin-top: 20px; padding-top: 20px; border-top: 1px solid #ddd; font-size: 12px; color: #999; }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h2>Novo Contato - Linear Hub Website</h2>
            </div>
            <div class="content">
              <div class="field">
                <div class="label">Nome:</div>
                <div class="value">${escapeHtml(name)}</div>
              </div>
              
              <div class="field">
                <div class="label">Email:</div>
                <div class="value"><a href="mailto:${escapeHtml(email)}">${escapeHtml(email)}</a></div>
              </div>
              
              ${company ? `
              <div class="field">
                <div class="label">Empresa:</div>
                <div class="value">${escapeHtml(company)}</div>
              </div>
              ` : ''}
              
              <div class="field">
                <div class="label">Assunto:</div>
                <div class="value">${escapeHtml(subject)}</div>
              </div>
              
              <div class="field">
                <div class="label">Mensagem:</div>
                <div class="value">${escapeHtml(message).replace(/\n/g, '<br>')}</div>
              </div>
              
              <div class="footer">
                <p>Este email foi enviado através do formulário de contato do Linear Hub Website</p>
                <p>Data: ${new Date().toLocaleString('pt-BR')}</p>
              </div>
            </div>
          </div>
        </body>
      </html>
    `;

    // Send email via Resend API
    const emailResponse = await sendViaResend({
      from: 'noreply@linear-hub.com.br',
      to: CONTACT_EMAIL,
      reply_to: email,
      subject: `[Website] ${subject}`,
      html: emailHTML,
    });

    if (!emailResponse.success) {
      console.error('Resend API error:', emailResponse.error);
      return {
        statusCode: 500,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ error: 'Failed to send email' }),
      };
    }

    console.log('Email sent successfully:', emailResponse.id);

    // Send to Slack (non-blocking)
    try {
      const slackWebhookUrl = process.env.SLACK_WEBHOOK_URL;
      if (slackWebhookUrl) {
        await sendSlackNotification(slackWebhookUrl, { name, email, company, subject, message });
      }
    } catch (error) {
      console.error('Slack notification failed (non-blocking):', error);
    }

    // Add to Notion (non-blocking)
    try {
      const notionApiKey = process.env.NOTION_API_KEY;
      const notionDatabaseId = process.env.NOTION_CONTACTS_DATABASE_ID;
      if (notionApiKey && notionDatabaseId) {
        await addContactToNotion(notionApiKey, notionDatabaseId, { name, email, company, subject, message });
      }
    } catch (error) {
      console.error('Notion logging failed (non-blocking):', error);
    }

    // Create Linear task (non-blocking)
    try {
      const linearApiKey = process.env.LINEAR_API_KEY;
      if (linearApiKey) {
        await createLinearTask(linearApiKey, subject, message, email);
      }
    } catch (error) {
      console.error('Linear task creation failed (non-blocking):', error);
    }

    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
      body: JSON.stringify({
        message: 'Email enviado com sucesso! Entraremos em contato em breve.',
        id: emailResponse.id,
      }),
    };

  } catch (error) {
    console.error('Error:', error);
    return {
      statusCode: 500,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ error: 'Internal server error' }),
    };
  }
};

// Helper: Send email via Resend API
async function sendViaResend(emailData) {
  return new Promise((resolve, reject) => {
    const payload = JSON.stringify(emailData);

    const options = {
      hostname: 'api.resend.com',
      port: 443,
      path: '/emails',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(payload),
        'Authorization': `Bearer ${RESEND_API_KEY}`,
      },
    };

    const req = https.request(options, (res) => {
      let data = '';

      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        try {
          const response = JSON.parse(data);
          if (res.statusCode === 200) {
            resolve({ success: true, id: response.id });
          } else {
            resolve({ success: false, error: response.message });
          }
        } catch (e) {
          reject(e);
        }
      });
    });

    req.on('error', (e) => {
      reject(e);
    });

    req.write(payload);
    req.end();
  });
}

// Helper: Escape HTML
function escapeHtml(unsafe) {
  return unsafe
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

// ============================================
// INTEGRATIONS: Slack, Notion, Linear
// ============================================

// Helper: Send Slack notification
async function sendSlackNotification(webhookUrl, contact) {
  const payload = {
    channel: '#contacts',
    blocks: [
      {
        type: 'header',
        text: {
          type: 'plain_text',
          text: '📬 Novo Contato - Website Linear Hub',
          emoji: true,
        },
      },
      {
        type: 'section',
        fields: [
          {
            type: 'mrkdwn',
            text: `*Nome:*\n${contact.name}`,
          },
          {
            type: 'mrkdwn',
            text: `*Email:*\n<mailto:${contact.email}|${contact.email}>`,
          },
          {
            type: 'mrkdwn',
            text: `*Assunto:*\n${contact.subject}`,
          },
          {
            type: 'mrkdwn',
            text: `*Empresa:*\n${contact.company || 'Não informado'}`,
          },
        ],
      },
      {
        type: 'section',
        text: {
          type: 'mrkdwn',
          text: `*Mensagem:*\n${contact.message.substring(0, 500)}${contact.message.length > 500 ? '...' : ''}`,
        },
      },
      {
        type: 'divider',
      },
      {
        type: 'context',
        elements: [
          {
            type: 'mrkdwn',
            text: `_Recebido em: ${new Date().toLocaleString('pt-BR')}_`,
          },
        ],
      },
    ],
  };

  return new Promise((resolve, reject) => {
    const payload_str = JSON.stringify(payload);
    const url = new URL(webhookUrl);

    const options = {
      hostname: url.hostname,
      path: url.pathname + url.search,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(payload_str),
      },
    };

    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });
      res.on('end', () => {
        if (res.statusCode === 200) {
          resolve({ success: true });
        } else {
          resolve({ success: false, error: data });
        }
      });
    });

    req.on('error', reject);
    req.write(payload_str);
    req.end();
  });
}

// Helper: Add contact to Notion
async function addContactToNotion(apiKey, databaseId, contact) {
  const payload = JSON.stringify({
    parent: { database_id: databaseId },
    properties: {
      Name: {
        title: [{ text: { content: contact.name } }],
      },
      Email: {
        email: contact.email,
      },
      Company: {
        rich_text: [{ text: { content: contact.company || 'N/A' } }],
      },
      Subject: {
        rich_text: [{ text: { content: contact.subject } }],
      },
      Message: {
        rich_text: [{ text: { content: contact.message } }],
      },
      Created: {
        date: { start: new Date().toISOString() },
      },
      Status: {
        select: { name: 'new' },
      },
    },
  });

  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'api.notion.com',
      path: '/v1/pages',
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${apiKey}`,
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
        try {
          const response = JSON.parse(data);
          if (res.statusCode === 200) {
            resolve({ success: true, id: response.id });
          } else {
            resolve({ success: false, error: response });
          }
        } catch (e) {
          resolve({ success: false, error: data });
        }
      });
    });

    req.on('error', reject);
    req.write(payload);
    req.end();
  });
}

// Helper: Create Linear task
async function createLinearTask(apiKey, title, description, email) {
  const escapedTitle = title.replace(/"/g, '\\"').replace(/\n/g, '\\n');
  const escapedDescription = description.replace(/"/g, '\\"').replace(/\n/g, '\\n');

  const query = `
    mutation {
      issueCreate(
        input: {
          teamId: "team-1"
          title: "${escapedTitle}"
          description: "${escapedDescription}\\n\\nContato: ${email}"
          priority: 3
        }
      ) {
        success
        issue {
          id
          identifier
        }
      }
    }
  `;

  const payload = JSON.stringify({ query });

  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'api.linear.app',
      path: '/graphql',
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(payload),
      },
    };

    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });
      res.on('end', () => {
        try {
          const response = JSON.parse(data);
          if (response.data?.issueCreate?.success) {
            resolve({ success: true, id: response.data.issueCreate.issue.id });
          } else {
            resolve({ success: false, error: response.errors || response });
          }
        } catch (e) {
          resolve({ success: false, error: data });
        }
      });
    });

    req.on('error', reject);
    req.write(payload);
    req.end();
  });
}
