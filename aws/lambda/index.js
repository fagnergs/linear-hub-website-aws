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
