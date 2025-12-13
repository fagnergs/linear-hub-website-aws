const https = require('https');

// Environment variable for Resend API key
const RESEND_API_KEY = process.env.RESEND_API_KEY;

async function sendEmailViaResend(emailData) {
  return new Promise((resolve, reject) => {
    const data = JSON.stringify(emailData);
    
    const options = {
      hostname: 'api.resend.com',
      port: 443,
      path: '/emails',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': data.length,
        'Authorization': `Bearer ${RESEND_API_KEY}`
      }
    };
    
    const req = https.request(options, (res) => {
      let responseData = '';
      
      res.on('data', (chunk) => {
        responseData += chunk;
      });
      
      res.on('end', () => {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          resolve(JSON.parse(responseData));
        } else {
          reject(new Error(`Resend API Error (${res.statusCode}): ${responseData}`));
        }
      });
    });
    
    req.on('error', (error) => {
      reject(error);
    });
    
    req.write(data);
    req.end();
  });
}

exports.handler = async (event) => {
  try {
    // Parse body
    const body = JSON.parse(event.body || '{}');
    const { name, email, company, subject, message } = body;
    
    // Validate required fields
    if (!name || !email || !subject || !message) {
      return {
        statusCode: 400,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
        body: JSON.stringify({
          message: 'Todos os campos obrigatórios devem ser preenchidos',
          error: 'Missing required fields'
        })
      };
    }
    
    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return {
        statusCode: 400,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
        body: JSON.stringify({
          message: 'Email inválido',
          error: 'Invalid email format'
        })
      };
    }
    
    // Check if API key is configured
    if (!RESEND_API_KEY) {
      console.error('RESEND_API_KEY not configured');
      return {
        statusCode: 500,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
        body: JSON.stringify({
          message: 'Erro ao enviar mensagem. Chave API não configurada.',
          error: 'RESEND_API_KEY not set'
        })
      };
    }
    
    // Send email via Resend
    const emailPayload = {
      from: 'Linear Hub <noreply@linear-hub.com.br>',
      to: ['contato@linear-hub.com.br'],
      reply_to: email,
      subject: `[Website] ${subject}`,
      html: `
        <!DOCTYPE html>
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
                  <div class="value">${name}</div>
                </div>
                <div class="field">
                  <div class="label">Email:</div>
                  <div class="value"><a href="mailto:${email}">${email}</a></div>
                </div>
                ${company ? `
                <div class="field">
                  <div class="label">Empresa:</div>
                  <div class="value">${company}</div>
                </div>
                ` : ''}
                <div class="field">
                  <div class="label">Assunto:</div>
                  <div class="value">${subject}</div>
                </div>
                <div class="field">
                  <div class="label">Mensagem:</div>
                  <div class="value">${message.replace(/\n/g, '<br>')}</div>
                </div>
                <div class="footer">
                  <p>Esta mensagem foi enviada através do formulário de contato do site Linear Hub em ${new Date().toLocaleString('pt-BR')}.</p>
                </div>
              </div>
            </div>
          </body>
        </html>
      `
    };
    
    const result = await sendEmailViaResend(emailPayload);
    
    console.log('Email sent successfully:', {
      id: result.id,
      from: result.from,
      created_at: result.created_at
    });
    
    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
      body: JSON.stringify({
        message: 'Mensagem enviada com sucesso! Entraremos em contato em breve.'
      })
    };
    
  } catch (error) {
    console.error('Contact API Error:', {
      message: error.message,
      timestamp: new Date().toISOString()
    });
    
    return {
      statusCode: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
      body: JSON.stringify({
        message: 'Erro ao enviar mensagem. Por favor, tente novamente mais tarde.',
        error: error.message
      })
    };
  }
};
