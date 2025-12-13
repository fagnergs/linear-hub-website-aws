const https = require('https');

// Environment variable for Resend API key
const RESEND_API_KEY = process.env.RESEND_API_KEY;

console.log('🚀 Lambda initialized');
console.log('✅ RESEND_API_KEY configured:', !!RESEND_API_KEY);

async function sendEmailViaResend(emailData) {
  return new Promise((resolve, reject) => {
    // Garantir que os dados são JSON válido
    let data;
    try {
      data = JSON.stringify(emailData);
    } catch (e) {
      reject(new Error('Failed to serialize email data: ' + e.message));
      return;
    }

    console.log('📤 Sending to Resend, payload size:', data.length, 'bytes');
    
    const options = {
      hostname: 'api.resend.com',
      port: 443,
      path: '/emails',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Content-Length': Buffer.byteLength(data),
        'Authorization': `Bearer ${RESEND_API_KEY}`
      }
    };
    
    const req = https.request(options, (res) => {
      let responseData = '';
      
      res.on('data', (chunk) => {
        responseData += chunk;
      });
      
      res.on('end', () => {
        console.log(`📬 Resend response status: ${res.statusCode}`);
        
        if (res.statusCode >= 200 && res.statusCode < 300) {
          try {
            const parsed = JSON.parse(responseData);
            resolve(parsed);
          } catch (e) {
            console.warn('Failed to parse Resend response, returning partial data');
            resolve({ id: 'unknown', created_at: new Date().toISOString() });
          }
        } else {
          console.error(`Resend API error response: ${responseData}`);
          reject(new Error(`Resend API Error (${res.statusCode}): ${responseData}`));
        }
      });
    });
    
    req.on('error', (error) => {
      console.error('Request error:', error.message);
      reject(error);
    });
    
    req.write(data);
    req.end();
  });
}

exports.handler = async (event) => {
  console.log('📨 Request received:', {
    httpMethod: event.httpMethod,
    path: event.path,
    bodyType: typeof event.body,
    isBase64: event.isBase64Encoded
  });

  // Add CORS headers
  const headers = {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
  };

  // Handle OPTIONS request
  if (event.httpMethod === 'OPTIONS') {
    return { statusCode: 200, headers, body: '{}' };
  }

  if (event.httpMethod !== 'POST') {
    return {
      statusCode: 405,
      headers,
      body: JSON.stringify({ message: 'Method not allowed' })
    };
  }

  try {
    // Parse body - handle various formats
    let body = {};
    
    if (event.body) {
      if (typeof event.body === 'string') {
        // Decode base64 if needed
        let bodyStr = event.body;
        if (event.isBase64Encoded) {
          bodyStr = Buffer.from(event.body, 'base64').toString('utf-8');
        }
        try {
          body = JSON.parse(bodyStr);
        } catch (e) {
          console.error('Failed to parse body:', bodyStr);
          throw new Error('Invalid JSON in request body');
        }
      } else if (typeof event.body === 'object') {
        body = event.body;
      }
    }
    
    const { name, email, company, subject, message } = body;
    
    console.log('📝 Form data:', { name, email, company, subject, message: message ? 'present' : 'missing' });

    // Validate required fields
    if (!name || !email || !subject || !message) {
      console.warn('❌ Missing required fields');
      return {
        statusCode: 400,
        headers,
        body: JSON.stringify({
          message: 'Todos os campos obrigatórios devem ser preenchidos (nome, email, assunto, mensagem)',
          error: 'Missing required fields'
        })
      };
    }

    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      console.warn('❌ Invalid email format:', email);
      return {
        statusCode: 400,
        headers,
        body: JSON.stringify({
          message: 'Email inválido',
          error: 'Invalid email format'
        })
      };
    }

    // Check if API key is configured
    if (!RESEND_API_KEY) {
      console.error('❌ RESEND_API_KEY not configured');
      return {
        statusCode: 500,
        headers,
        body: JSON.stringify({
          message: 'Erro ao enviar mensagem. Chave API não configurada.',
          error: 'RESEND_API_KEY not set'
        })
      };
    }

    console.log('📧 Preparing email...');

    // Send email via Resend
    const emailPayload = {
      from: 'Linear Hub <noreply@linear-hub.com.br>',
      to: ['contato@linear-hub.com.br'],
      reply_to: email,
      subject: `[Website] ${subject}`,
      html: generateEmailHTML(name, email, company, subject, message)
    };

    console.log('🔄 Sending to Resend API...');
    const result = await sendEmailViaResend(emailPayload);

    console.log('✅ Email sent successfully:', {
      id: result.id,
      from: result.from || 'noreply@linear-hub.com.br',
      created_at: result.created_at
    });

    return {
      statusCode: 200,
      headers,
      body: JSON.stringify({
        message: 'Mensagem enviada com sucesso! Entraremos em contato em breve.',
        id: result.id
      })
    };

  } catch (error) {
    console.error('❌ Lambda Error:', {
      message: error.message,
      stack: error.stack,
      timestamp: new Date().toISOString()
    });

    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({
        message: 'Erro ao enviar mensagem. Por favor, tente novamente mais tarde.',
        error: error.message
      })
    };
  }
};

function generateEmailHTML(name, email, company, subject, message) {
  // Sanitize and escape all inputs
  const safeName = escapeHtml(name || '');
  const safeEmail = escapeHtml(email || '');
  const safeCompany = escapeHtml(company || '');
  const safeSubject = escapeHtml(subject || '');
  const safeMessage = escapeHtml(message || '').replace(/\n/g, '<br>');

  return `<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <style>
      body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
      .container { max-width: 600px; margin: 0 auto; padding: 20px; }
      .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; border-radius: 8px 8px 0 0; }
      .content { background: #f9fafb; padding: 30px; border-radius: 0 0 8px 8px; }
      .field { margin-bottom: 20px; }
      .label { font-weight: bold; color: #667eea; margin-bottom: 5px; }
      .value { background: white; padding: 12px; border-radius: 4px; border-left: 3px solid #667eea; }
      .footer { margin-top: 30px; padding-top: 20px; border-top: 2px solid #e5e7eb; font-size: 12px; color: #6b7280; }
    </style>
  </head>
  <body>
    <div class="container">
      <div class="header">
        <h2 style="margin: 0;">Nova Mensagem do Site - Linear Hub</h2>
      </div>
      <div class="content">
        <div class="field">
          <div class="label">Nome:</div>
          <div class="value">${safeName}</div>
        </div>
        <div class="field">
          <div class="label">Email:</div>
          <div class="value"><a href="mailto:${safeEmail}">${safeEmail}</a></div>
        </div>
        ${company ? `
        <div class="field">
          <div class="label">Empresa:</div>
          <div class="value">${safeCompany}</div>
        </div>
        ` : ''}
        <div class="field">
          <div class="label">Assunto:</div>
          <div class="value">${safeSubject}</div>
        </div>
        <div class="field">
          <div class="label">Mensagem:</div>
          <div class="value">${safeMessage}</div>
        </div>
        <div class="footer">
          <p>Esta mensagem foi enviada através do formulário de contato do site Linear Hub em ${new Date().toLocaleString('pt-BR')}.</p>
        </div>
      </div>
    </div>
  </body>
</html>`;
}

function escapeHtml(text) {
  if (!text) return '';
  const map = {
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#039;'
  };
  return text.replace(/[&<>"']/g, m => map[m]);
}
